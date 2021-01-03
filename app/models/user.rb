class User < ApplicationRecord
  has_secure_password

  has_many :owned_matchups, class_name: "Matchup", foreign_key: "owner_id"
  has_many :user_matchups
  has_many :matchups, through: :user_matchups
  has_many :picks, through: :user_matchups


  validates_presence_of :name, :email, :password
  validates_uniqueness_of :email

  def active_matchups
    self.matchups.where(status: "Active").limit(5)
  end

  def recent_picks
    self.picks.order("id DESC").limit(5)
  end

  # find a better way to write this before using
  def best_picks
    self.picks.sort_by{|pick| pick.points}.reverse!.first(5)
  end

  def recent_goals
    
  end

  # def frequent_opponents
  #   self.matchups.joins(:user_matchups, :users).where.not(user_matchup.user: self).group(:user).count
  # end

  def matchups_requiring_action
    self.matchups.select{|matchup| matchup.status == "Draft" && matchup.whose_pick?.user == self}
  end

end
