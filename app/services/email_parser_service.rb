# The EmailParserService is responsible for parsing email data from a message
# retrieved via an external email service (like Gmail). It extracts and formats
# key pieces of information from the email message, such as the sender, subject,
# and date, for further processing or storage.
#
# @example Creating an instance and parsing an email message
#   parser = EmailParserService.new(message_info, user)
#   parsed_data = parser.parse
#
class EmailParserService
  # Initializes the EmailParserService with the given message and user.
  #
  # @param message_info [Object] The email message object retrieved from an external service.
  # @param user [User] The user associated with the email message.
  def initialize(message_info, user)
    @message_info = message_info
    @headers = message_info.payload.headers
    @user = user
  end

  # Parses the email message and extracts key data.
  # Extracts and returns a hash with the gmail_id, sender, subject, email date, and user ID.
  # If the email date is in an invalid format, the parsing fails and logs a warning.
  #
  # @return [Hash, nil] A hash containing the parsed email data or nil if parsing fails.
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

  # Retrieves the email date from the message headers.
  #
  # @return [DateTime, nil] The parsed DateTime object for the email date or nil if not found.
  def email_date
    @email_date ||= self.class.parse_date(find_header_value("Date"))
  end

  # Finds and returns the value of a specified header from the email message.
  #
  # @param name [String] The name of the header to find.
  # @return [String, nil] The value of the header or nil if not found.
  def find_header_value(name)
    @headers.find { |header| header.name == name }&.value
  end

  # Parses a date string into a DateTime object.
  # This method is a class method and can be used without an instance of the service.
  #
  # @param date_str [String] The date string to be parsed.
  # @return [DateTime] The parsed DateTime object.
  # @raise [ArgumentError] If the date string is in an invalid format.
  def self.parse_date(date_str)
    DateTime.parse(date_str)
  end
end
