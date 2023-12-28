require "google/apis/gmail_v1"
require "google/api_client/client_secrets"

class GmailAdapter
  class Error < StandardError; end

  class AuthorizationError < StandardError; end

  def initialize(user)
    @user = user
    @client = setup_gmail_client
  end

  def list_user_messages(label_id, max_results, page_token, query = nil)
    safe_api_call do
      client.list_user_messages(
        user.email,
        label_ids: [label_id],
        max_results: max_results,
        page_token: page_token,
        q: query
      )
    end
  end

  def get_user_message(message_id)
    safe_api_call do
      client.get_user_message(user.email, message_id)
    end
  end

  private

  attr_reader :user, :client

  def setup_gmail_client
    client = Google::Apis::GmailV1::GmailService.new
    client.authorization = user_credentials
    client
  end

  def user_credentials
    Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => user.token,
        "refresh_token" => user.refresh_token,
        "client_id" => A9n.google_client_id,
        "client_secret" => A9n.google_client_secret
      }
    }).to_authorization.tap do |auth|
      auth.grant_type = "refresh_token"
    end
  end

  def safe_api_call(retries: 5)
    retry_counter = 0
    begin
      yield
    rescue Google::Apis::AuthorizationError => e
      handle_authorization_error(e)
    rescue Google::Apis::RateLimitError => e
      handle_rate_limit_error(e, retry_counter)
      retry if (retry_counter += 1) < retries
    rescue Google::Apis::Error => e
      raise Error, e.message
    end
  end

  def handle_authorization_error(error)
    refresh_token!
  rescue => e
    Rails.logger.error("Authorization error: #{error.message}. Token refresh failed: #{e.message}")
    raise AuthorizationError, "Token expired or invalid. Please log in again."
  end

  def refresh_token!
    client.authorization.fetch_access_token!
    update_user_credentials
  end

  def update_user_credentials
    authorization = client.authorization
    user.update!(
      token: authorization.access_token,
      refresh_token: authorization.refresh_token
    )
  end

  def handle_rate_limit_error(error, counter)
    Rails.logger.warn("Rate limit error: #{error}, retrying #{counter}")
    sleep(1)
  end
end
