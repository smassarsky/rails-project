class Pick < ApplicationRecord
  belongs_to :user_matchup
  has_one :user, through: :user_matchup
  belongs_to :player
end
