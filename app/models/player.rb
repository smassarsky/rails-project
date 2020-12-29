class Player < ApplicationRecord
  has_many :game_players
  has_many :teams, through: :game_players
  has_many :games, through: :game_players

  has_many :goals
  has_many :assists

  validates_presence_of :name
  validates_uniqueness_of :name

  def position_in_games(games)
    self.game_players.where(game: games).select(:position).distinct
  end

  # Player.joins(:game_players).where(game_players: {team: self.team, game: self.related_games}).distinct

end
