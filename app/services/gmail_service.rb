require "google/apis/gmail_v1"
require "google/api_client/client_secrets"
require "date"

class GmailService
  def initialize(user)
    @user = user
  end

  def retrieve_last_email_info
    user_email = user.email
    label_id = "INBOX"
    max_results = 1
    messages = google_gmail_client.list_user_messages(user_email, label_ids: [label_id], max_results: max_results)

    if messages&.messages&.any?
      last_message_id = messages.messages.first.id
      last_message = google_gmail_client.get_user_message(user_email, last_message_id)

      sender = last_message.payload.headers.find { |header| header.name == "From" }&.value
      subject = last_message.payload.headers.find { |header| header.name == "Subject" }&.value
      date_header = last_message.payload.headers.find { |header| header.name == "Date" }&.value
      date = DateTime.parse(date_header)

      email = user.emails.create(sender: sender, subject: subject, email_date: date.to_date, email_datetime: date)

      email.persisted? ? email : {error: "Failed to save email"}
    else
      {error: "No messages found"}
    end
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
