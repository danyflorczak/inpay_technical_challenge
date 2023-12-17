class EmailProcessingService
  def initialize(user)
    @user = user
  end

  def process_and_save_emails(emails)
    ActiveRecord::Base.transaction do
      email_records = emails.map { |email| build_email_record(email) }
      save_email_records(email_records) unless email_records.empty?
    end
    {success: "Successfully saved all mail records"}
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Error in EmailProcessingService: #{e.message}"
    {error: "Failed to save emails"}
  end

  private

  attr_reader :user

  def build_email_record(message_info)
    headers = message_info.payload.headers
    {
      gmail_id: message_info.id,
      sender: find_header_value(headers, "From"),
      subject: find_header_value(headers, "Subject"),
      email_date: parse_date(find_header_value(headers, "Date")).to_date,
      email_datetime: parse_date(find_header_value(headers, "Date")),
      user_id: user.id
    }
  end

  def save_email_records(email_records)
    existing_gmail_ids = Email.where(gmail_id: email_records.pluck(:gmail_id)).pluck(:gmail_id)
    new_records = email_records.reject { |record| existing_gmail_ids.include?(record[:gmail_id]) }
    Email.insert_all(new_records) unless new_records.empty?
  end

  def find_header_value(headers, name)
    headers.find { |header| header.name == name }&.value
  end

  def parse_date(date_str)
    DateTime.parse(date_str)
  end
end
