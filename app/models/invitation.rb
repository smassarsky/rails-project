class Invitation < ApplicationRecord
  belongs_to :matchup

  attribute :code, :string, default: -> {SecureRandom.hex}

  validates_uniqueness_of :code
end
