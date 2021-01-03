class Invitation < ApplicationRecord
  belongs_to :matchup
  has_one :owner, through: :matchup

  before_save :nickname_nil_if_empty

  attribute :code, :string, default: -> {SecureRandom.hex}

  validates_uniqueness_of :code

  private

  def nickname_nil_if_empty
    self.nickname = nil if self.nickname.empty?
  end
  
end
