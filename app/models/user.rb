# The User model represents a user in the system. It manages user information
# and authentication exclusively for OAuth-based authentication.
# Each user can have multiple associated Email records.
#
# @!attribute [r] email
#   @return [String] The email address of the user.
# @!attribute [r] provider
#   @return [String] The OAuth provider for the user.
# @!attribute [r] uid
#   @return [String] The unique identifier for the user from the OAuth provider.
# @!attribute [r] token
#   @return [String] The OAuth token for the user.
# @!attribute [r] refresh_token
#   @return [String] The OAuth refresh token for the user.
#
class User < ApplicationRecord
  # Association with the Email model.
  # Dependent: :destroy ensures that emails are deleted when the user is deleted.
  has_many :emails, dependent: :destroy

  # Configures the OmniAuth (OAuth) providers.
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  # Creates or finds a user from an OmniAuth access token.
  # @param access_token [OmniAuth::AuthHash] The OmniAuth access token containing user data.
  # @return [User] The found or created user.
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
