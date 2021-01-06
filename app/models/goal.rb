class Goal < ApplicationRecord
  belongs_to :game
  has_many :assists

  belongs_to :player
  belongs_to :team

  def opponent
    (self.game.teams - [self.team]).first.full_team_name
  end

  def has_video?
    self.video_url != nil
  end

  def assist_players
    self.assists.joins(:player)
  end

  def assist_names
    self.assists.map{|assist| assist.player.name}
  end

  def player_name
    self.player.name
  end

  def game_time
    self.game.datetime
  end

end
