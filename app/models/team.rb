class Team < ApplicationRecord
  has_many :game_players
  has_many :goals, through: :game_players
  has_many :assists, through: :game_players

  has_many :matchups

  has_many :home_games, class_name: "Game", foreign_key: "home_team_id"
  has_many :away_games, class_name: "Game", foreign_key: "away_team_id"

  def games
    home_games.or(away_games)
  end

  def full_team_name
    "#{self.city} #{self.name}"
  end

end
