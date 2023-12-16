class User < ApplicationRecord
  has_many :emails, dependent: :destroy
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(access_token)
    find_or_create_by(provider: access_token.provider, email:
      access_token.info.email) do |user|
      user.provider = access_token.provider
      user.uid = access_token.uid
      user.email = access_token.info.email
      user.token = access_token.credentials.token
      user.refresh_token = access_token.credentials.refresh_token
      user.save!
    end
  end
end
