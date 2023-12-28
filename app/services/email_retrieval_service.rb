class EmailRetrievalService
  MAX_RESULTS = 500
  INBOX_LABEL = "INBOX"

  def initialize(user)
    @gmail_adapter = GmailAdapter.new(user)
  end

  def fetch_emails(start_date = nil, end_date = nil)
    query = build_query(start_date, end_date)
    collect_emails(query)
  end

  private

  attr_reader :gmail_adapter

  def collect_emails(query = nil)
    emails = []
    process_messages(INBOX_LABEL, query) do |message_info|
      emails << message_info
    end
    emails
  end

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

  def build_query(start_date, end_date)
    if start_date && end_date
      "after:#{self.class.parse_date(start_date).strftime("%Y/%m/%d")} " \
      "before:#{self.class.parse_date(end_date).strftime("%Y/%m/%d")}"
    end
  end

  def self.parse_date(date)
    date.is_a?(Date) ? date : Date.parse(date)
  end
end
