class UserMatchup < ApplicationRecord
  belongs_to :matchup
  belongs_to :user
  has_many :picks

  def display_name
    "#{self.user.name}#{" (#{self.nickname})" if self.nickname}"
  end

  def total_points
    self.picks.sum{|pick| pick.points}
  end

end
