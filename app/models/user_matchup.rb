class UserMatchup < ApplicationRecord
  belongs_to :matchup
  belongs_to :user
  has_many :picks

  def display_name
    "#{self.user.name}#{" (#{self.nickname})" if self.nickname}"
  end

end
