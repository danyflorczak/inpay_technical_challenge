class EmailParserService
  def initialize(message_info, user)
    @message_info = message_info
    @headers = message_info.payload.headers
    @user = user
  end

  def parse
    gmail_id = @message_info.id
    {
      gmail_id: gmail_id,
      sender: find_header_value("From"),
      subject: find_header_value("Subject"),
      email_date: email_date&.to_date,
      email_datetime: email_date,
      user_id: @user.id
    }
  rescue ArgumentError
    Rails.logger.warn "Invalid date format in email: #{gmail_id}"
    nil
  end

  private

  def email_date
    @email_date ||= self.class.parse_date(find_header_value("Date"))
  end

  def find_header_value(name)
    @headers.find { |header| header.name == name }&.value
  end

  def self.parse_date(date_str)
    DateTime.parse(date_str)
  end
end
