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
end
