class Game < ApplicationRecord
  has_many :goals
  has_many :assists, through: :goals

  has_many :game_players
  has_many :players, through: :game_players

  has_many :game_teams
  has_many :teams, through: :game_teams

  def home_team=(team)
    self.game_teams.build(team: team, home_away: 'home')
  end

  def away_team=(team)
    self.game_teams.build(team: team, home_away: 'away')
  end

  def home_team
    self.game_teams.find_by(home_away: 'home').team
  end

  def away_team
    self.game_teams.find_by(home_away: 'away').team
  end

  def home_team_goals
    self.goals.where(team: self.home_team)
  end

  def away_team_goals
    self.goals.where(team: self.away_team)
  end

  def score
    if self.status != "Preview"
      {
        home: {
          team: self.home_team.full_team_name,
          goals: self.home_team_goals.count
        },
        away: {
          team: self.away_team.full_team_name,
          goals: self.away_team_goals.count
        }
      }
    else
      "TBD"
    end
  end

  def opponent(team)
    self.teams.where("teams.id != ?", team).first
  end

  def win_loss_score(team)
    if self.status != "Preview"
      team_goals = self.goals.where(team: team).count
      opponent_goals = self.goals.where.not(team: team).count
      "#{team_goals > opponent_goals ? 'win' : 'loss'} #{team_goals} - #{opponent_goals}"
    else
      "TBD"
    end
  end

  def team_players(team)
    self.game_players.where(team: team).select(:player)
  end

end
