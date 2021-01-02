class Goal < ApplicationRecord
  belongs_to :game
  has_many :assists

  belongs_to :player
  belongs_to :team

  def has_video?
    self.video_url != nil
  end

end
