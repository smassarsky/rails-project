class Matchup < ApplicationRecord
  belongs_to :owner, class_name: "User"
  belongs_to :team
  has_many :user_matchups
  has_many :users, through: :user_matchups
  has_many :picks, through: :user_matchups
  has_many :players, through: :picks
  has_many :game_players, through: :players
  has_many :games, through: :game_players
  has_many :goals, through: :games
  has_many :assists, through: :goals
  has_many :invitations

  validates_presence_of :name, :start_date, :end_date, :team
  validates :status, inclusion: %w[Pre-Draft Draft Active Complete]
  validate :dates

  before_validation :def_status


  def team_name
    self.team.name
  end

  def invitations_count
    self.invitations.count
  end

  def users_count
    self.users.count
  end

  def potential_users_count
    invitations_count + users_count
  end

  def full?
    potential_users_count > 3
  end

  def start_draft
    if self.users_count > 1
      delete_extra_invitations
      self.update(status: "Draft")
      set_draft_order
    else
      false
    end
  end

  def end_draft
    self.update(status: "Active")
  end

  # this ought to be changed at some point so the tz offset isn't hardcoded for est
  def related_games
    self.team.games.where("datetime >= ? AND datetime <= ?", self.start_date, self.end_date + 1.day + 5.hours)
  end

  def related_players
    Player.joins(:game_players).where(game_players: {team: self.team, game: self.related_games}).distinct
  end

  def available_players
    self.related_players - self.players
  end

  def user_picks(user)
    self.user_matchups.find_by(user: user).picks
  end

  def season
    self.related_games.first.season
  end

  def whose_pick?
    self.user_matchups.find_by(draft_order: num_of_picks % users_count)
  end

  def draft_done?
    self.num_of_picks == self.max_picks
  end

  def num_of_picks
    self.picks.count
  end

  def max_picks
    users_count * 4
  end

  private

  def dates

    if start_date >= end_date
      errors.add(:start_date, "Must be before end date.")
      errors.add(:end_date, "Must be after start date.")
    end
  end

  def def_status
    self.status = "Pre-Draft" if self.status.nil?
  end

  def set_draft_order
    self.user_matchups.order('random()').each_with_index do |usermatchup, index|
      usermatchup.update(draft_order: index)
    end
  end

  def delete_extra_invitations
    self.invitations.destroy_all
  end





end
