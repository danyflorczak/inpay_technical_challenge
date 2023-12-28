# GmailAdapter is responsible for interacting with the Google Gmail API.
# It provides methods to list and retrieve user messages, handle authorization,
# and deal with common API errors such as rate limits and authorization failures.
#
# @example Initialize the adapter for a user
#   adapter = GmailAdapter.new(user)
# @example List user messages
#   messages = adapter.list_user_messages(label_id, max_results, page_token)
# @example Get a specific message
#   message = adapter.get_user_message(message_id)
#
class GmailAdapter
  # Error class for general Gmail API errors
  class Error < StandardError; end

  # Error class for authorization errors with Gmail API
  class AuthorizationError < StandardError; end

  # Initializes a new instance of GmailAdapter.
  #
  # @param user [User] The user instance for which the adapter is being initialized.
  def initialize(user)
    @user = user
    @client = setup_gmail_client
  end

  # Lists messages for a user.
  #
  # @param label_id [String] Gmail label ID to filter messages.
  # @param max_results [Integer] Maximum number of messages to retrieve.
  # @param page_token [String, nil] Token for pagination.
  # @param query [String, nil] Query string for filtering messages.
  # @return [Array, nil] An array of messages or nil if an error occurs.
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

  # Retrieves a specific user message.
  #
  # @param message_id [String] The ID of the message to retrieve.
  # @return [Object, nil] The message object or nil if an error occurs.
  def get_user_message(message_id)
    safe_api_call do
      client.get_user_message(user.email, message_id)
    end
  end

  private

  attr_reader :user, :client

  # Setups the Gmail API client with user credentials.
  #
  # @return [Google::Apis::GmailV1::GmailService] The configured Gmail service client.
  def setup_gmail_client
    client = Google::Apis::GmailV1::GmailService.new
    client.authorization = user_credentials
    client
  end

  # Constructs and returns user credentials for the Gmail API.
  #
  # @return [Google::APIClient::ClientSecrets] The user's authorization credentials.
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

  # Executes a Gmail API call safely with error handling.
  #
  # @yield The block to execute that includes the Gmail API call.
  # @param retries [Integer] The number of retries for rate limit errors (default: 5).
  # @raise [GmailAdapter::Error] If a non-recoverable error occurs.
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

  # Handles authorization errors by refreshing the user's token.
  #
  # @raise [GmailAdapter::AuthorizationError] If token refresh fails.
  def handle_authorization_error(error)
    refresh_token!
  rescue => e
    Rails.logger.error("Authorization error: #{error.message}. Token refresh failed: #{e.message}")
    raise AuthorizationError, "Token expired or invalid. Please log in again."
  end

  # Refreshes the user's authorization token.
  #
  # @raise [StandardError] If token refresh fails.
  def refresh_token!
    client.authorization.fetch_access_token!
    update_user_credentials
  end

  # Updates user credentials with new token information.
  #
  def update_user_credentials
    authorization = client.authorization
    user.update!(
      token: authorization.access_token,
      refresh_token: authorization.refresh_token
    )
  end

  # Handles rate limit errors by logging and retrying.
  #
  # @param error [Google::Apis::RateLimitError] The rate limit error encountered.
  # @param counter [Integer] The current retry count.
  def handle_rate_limit_error(error, counter)
    Rails.logger.warn("Rate limit error: #{error}, retrying #{counter}")
    sleep(1)
  end
end
