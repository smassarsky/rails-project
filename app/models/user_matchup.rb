class UserMatchup < ApplicationRecord
  belongs_to :matchup
  belongs_to :user
  has_many :picks
  has_many :players, through: :picks

  def display_name
    "#{self.user.name}#{" (#{self.nickname})" if self.nickname}"
  end

  def total_points
    self.picks.sum{|pick| pick.points}
  end

  def goals
    Goal.where(player: self.players, game: self.matchup.related_games)
  end

  def assists
    Assist.joins(:goal).where(assists: {player: self.players}, goals: {game: self.matchup.related_games})
  end

end
