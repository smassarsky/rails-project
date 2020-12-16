class UserMatchup < ApplicationRecord
  belongs_to :matchup
  belongs_to :user
  has_many :picks
end
