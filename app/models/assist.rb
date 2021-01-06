class Assist < ApplicationRecord
  belongs_to :goal
  has_one :game, through: :goal
  has_one :team, through: :goal

  belongs_to :player

  def opponent
    (self.game.teams - [self.team]).first
  end

  def scorer
    self.goal.player.name
  end

  def player_name
    self.player.name
  end

  def period
    self.goal.period
  end

  def time
    self.goal.time
  end

  def has_video?
    self.goal.has_video?
  end

  def video_url
    self.goal.video_url
  end

  def game_time
    self.game.datetime
  end

end
