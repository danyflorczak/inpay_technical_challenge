require "date"

class GmailMailboxProcessor
  def initialize(user)
    @user = user
    @gmail_adapter = GmailAdapter.new(user)
  end

  def retrieve_and_save_all_email_info
    ActiveRecord::Base.transaction do
      email_records = fetch_all_email_records
      save_email_records(email_records) unless email_records.empty?
    end
    {success: "Successfully saved all mail records"}
  rescue GmailAdapter::Error, ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error in GmailMailboxProcessor: #{e.message}"
    {error: "Failed to retrieve or save emails"}
  end

  private

  attr_reader :gmail_adapter, :user

  def fetch_all_email_records
    email_records = []
    process_messages("INBOX", 500) do |message_info|
      email_records << build_email_record(message_info)
    end
    email_records
  end

  def process_messages(label_id, max_results)
    page_token = nil
    loop do
      response = gmail_adapter.list_user_messages(label_id, max_results, page_token)
      break unless response.messages&.any?

      response.messages.each do |message|
        message_info = gmail_adapter.get_user_message(message.id)
        yield message_info
      end

      page_token = response.next_page_token
      break unless page_token
    end
  end

  def build_email_record(message_info)
    headers = message_info.payload.headers
    {
      sender: find_header_value(headers, "From"),
      subject: find_header_value(headers, "Subject"),
      email_date: parse_date(find_header_value(headers, "Date")).to_date,
      email_datetime: parse_date(find_header_value(headers, "Date")),
      user_id: user.id
    }
  end

  def save_email_records(email_records)
    Email.insert_all(email_records)
  end

  def find_header_value(headers, name)
    headers.find { |header| header.name == name }&.value
  end

  def parse_date(date_str)
    DateTime.parse(date_str)
  end
end
