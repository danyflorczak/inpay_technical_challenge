# The EmailRetrievalService is responsible for fetching email messages for a user.
# It interfaces with an email service (e.g., Gmail) to retrieve email messages,
# potentially within a specified date range. It uses the GmailAdapter to interact
# with the Gmail API.
#
# @example Initialize the service and fetch emails
#   email_service = EmailRetrievalService.new(user)
#   emails = email_service.fetch_emails('2023-01-01', '2023-01-31')
#
class EmailRetrievalService
  # Maximum number of email results to fetch in a single API call.
  MAX_RESULTS = 500

  # Default label for fetched emails.
  INBOX_LABEL = "INBOX"

  # Initializes the EmailRetrievalService with a user.
  #
  # @param user [User] The user for whom emails will be fetched.
  def initialize(user)
    @gmail_adapter = GmailAdapter.new(user)
  end

  # Fetches emails for the initialized user, optionally within a given date range.
  #
  # @param start_date [String, Date, nil] The start date for fetching emails.
  # @param end_date [String, Date, nil] The end date for fetching emails.
  # @return [Array<Object>] An array of email objects retrieved.
  def fetch_emails(start_date = nil, end_date = nil)
    query = build_query(start_date, end_date)
    collect_emails(query)
  end

  private

  attr_reader :gmail_adapter

  # Collects emails based on a specified query.
  # Iteratively fetches emails and accumulates them in an array.
  #
  # @param query [String, nil] The query string used to filter emails.
  # @return [Array<Object>] An array of email objects retrieved.
  def collect_emails(query = nil)
    emails = []
    process_messages(INBOX_LABEL, query) do |message_info|
      emails << message_info
    end
    emails
  end

  # Processes email messages from the Gmail API.
  # Fetches emails in pages, yielding each email to the provided block.
  #
  # @param label_id [String] The label ID to filter messages in Gmail.
  # @param query [String, nil] The query string used to filter messages.
  # @yield [Object] Yields each email message to the block.
  def process_messages(label_id, query = nil)
    page_token = nil
    loop do
      response = gmail_adapter.list_user_messages(label_id, MAX_RESULTS, page_token, query)
      break unless (messages = response.messages)&.any?

      messages.each do |message|
        yield gmail_adapter.get_user_message(message.id)
      end

      page_token = response.next_page_token
      break unless page_token
    end
  end

  # Builds a query string for fetching emails within a date range.
  #
  # @param start_date [String, Date] The start date of the range.
  # @param end_date [String, Date] The end date of the range.
  # @return [String, nil] The constructed query string or nil if no dates are provided.
  def build_query(start_date, end_date)
    if start_date && end_date
      "after:#{self.class.parse_date(start_date).strftime("%Y/%m/%d")} " \
        "before:#{self.class.parse_date(end_date).strftime("%Y/%m/%d")}"
    end
  end

  # Parses a date string or object into a Date.
  # This method is a class method and can be used without an instance of the service.
  #
  # @param date [String, Date] The date to be parsed.
  # @return [Date] The parsed Date object.
  def self.parse_date(date)
    date.is_a?(Date) ? date : Date.parse(date)
  end
end
