class Player < ApplicationRecord
  has_many :game_players
  has_many :teams, through: :game_players
  has_many :games, through: :game_players

  has_many :goals
  has_many :assists

  validates_presence_of :name
  validates_uniqueness_of :name
end
