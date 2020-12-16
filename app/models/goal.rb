class Goal < ApplicationRecord
  belongs_to :game
  has_many :assists

  belongs_to :player
  belongs_to :team
end
