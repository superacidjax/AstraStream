class ApiKey < ApplicationRecord
  encrypts :api_secret, deterministic: true

  validates :api_secret, uniqueness: true
  validates :application_id, presence: true, uniqueness: true

  before_create :generate_api_secret

  private

  def generate_api_secret
    self.api_secret = SecureRandom.base58(30)
  end
end
