class Player < ApplicationRecord
  has_many :game_players
  has_many :teams, through: :game_players
  has_many :games, through: :game_players

  has_many :goals
  has_many :assists

  validates_presence_of :name
  validates_uniqueness_of :name

  def position_in_games(games)
    self.game_players.find_by(game: games).position
  end

  def jersey_in_games(games)
    self.game_players.find_by(game: games).jersey_num
  end

  def regular_season_stats(season)
    games = self.games.where(season: season, game_type: "R")
    "#{games.count} GP | #{self.points_in_games(games).count} P | #{self.goals_in_games(games).count} G | #{self.assists_in_games(games).count} A"
  end

  def regular_season_stats_hash(season)
    games = self.games.where(season: season, game_type: "R")
    stats = {
      games_played: games.count,
      goals: self.goals_in_games(games).count,
      assists: self.assists_in_games(games).count
    }
    stats[:points] = stats[:goals] + stats[:assists]
    stats
  end

  def goals_in_games(games)
    self.goals.where(game: games)
  end

  def assists_in_games(games)
    self.assists.joins(:goal).where(goals: {game: games})
  end

  def points_in_games(games)
    self.goals_in_games(games) + self.assists_in_games(games)
  end

end
