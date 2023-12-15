require "google/apis/gmail_v1"
require "google/api_client/client_secrets"
require "date"

class GmailService
  def initialize(user)
    @user = user
  end

  def retrieve_all_email_info
    user_email = user.email
    label_id = "INBOX"
    max_results = 500
    page_token = nil

    loop do
      response = google_gmail_client.list_user_messages(user_email, label_ids: [label_id], max_results: max_results, page_token: page_token)
      break unless response.messages&.any?

      response.messages.each do |message|
        message_info = google_gmail_client.get_user_message(user_email, message.id)

        sender = message_info.payload.headers.find { |header| header.name == "From" }&.value
        subject = message_info.payload.headers.find { |header| header.name == "Subject" }&.value
        date_str = message_info.payload.headers.find { |header| header.name == "Date" }&.value
        parsed_date = DateTime.parse(date_str)

        Email.create!(sender: sender, subject: subject, email_date: parsed_date.to_date, email_datetime: parsed_date, user_id: user.id)
      end

      page_token = response.next_page_token
      break unless page_token
    end

    {success: "Successfully saved all mail records"}
  rescue => e
    Rails.logger.error "Error retrieving emails: #{e.message}"
    {error: "Failed to retrieve emails"}
  end

  private

  attr_reader :user

  def google_gmail_client
    client = Google::Apis::GmailV1::GmailService.new

    begin
      client.authorization = secrets.to_authorization
      client.authorization.grant_type = "refresh_token"
    rescue => e
      Rails.logger.debug e.message
    end

    client
  end

  def secrets
    Google::APIClient::ClientSecrets.new({
      "web" => {
        "access_token" => user.token,
        "refresh_token" => user.refresh_token,
        "client_id" => A9n.google_client_id,
        "client_secret" => A9n.google_client_secret
      }
    })
  end
end
