class Team < ApplicationRecord
  has_many :game_players
  has_many :goals, through: :game_players
  has_many :assists, through: :game_players

  has_many :matchups

  has_many :game_teams
  has_many :games, through: :game_teams

  def full_team_name
    "#{self.city} #{self.name}"
  end

end
