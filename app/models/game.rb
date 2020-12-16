class Game < ApplicationRecord
  has_many :goals
  has_many :assists, through: :goals

  has_many :game_players
  has_many :players, through: :game_players

  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
end
