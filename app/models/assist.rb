class Assist < ApplicationRecord
  belongs_to :goal
  has_one :game, through: :goal
  has_one :team, through: :goal

  belongs_to :player
end
