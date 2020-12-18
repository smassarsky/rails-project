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

  private

  def dates

    if start_date >= end_date
      errors.add(:start_date, "Must be before end date.")
      errors.add(:end_date, "Must be after start date.")
    end
  end

  def def_status
    if self.status.nil?
      self.status = "Pre-Draft"
    end
  end

  def set_draft_order

  end

end
