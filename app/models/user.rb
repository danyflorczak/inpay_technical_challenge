class User < ApplicationRecord
  has_many :emails, dependent: :destroy
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  def self.from_omniauth(access_token)
    provider = access_token.provider
    email = access_token.info.email
    credentials = access_token.credentials

    find_or_create_by!(provider: provider, email: email) do |user|
      user.provider = provider
      user.uid = access_token.uid
      user.email = email
      user.token = credentials.token
      user.refresh_token = credentials.refresh_token
      user.save!
    end
  end
end
