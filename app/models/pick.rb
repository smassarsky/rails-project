class Pick < ApplicationRecord
  belongs_to :user_matchup
  has_one :user, through: :user_matchup
  has_one :matchup, through: :user_matchup
  belongs_to :player

  def games
    self.matchup.related_games.merge(self.player.games)
  end

  def stats_in_matchup
    stats = {
      games_played: self.games.count,
      goals: self.player.goals_in_games(self.games).count,
      assists: self.player.assists_in_games(self.games).count,
    }
    stats[:points] = stats[:goals] + stats[:assists]
    stats
  end

  def goals
    self.player.goals_in_games(self.matchup.related_games)
  end

  def assists
    self.player.assists_in_games(self.matchup.related_games)
  end

  def points
    self.goals.count + self.assists.count
  end

end
