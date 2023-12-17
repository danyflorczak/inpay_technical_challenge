class EmailRetrievalService
  def initialize(user)
    @gmail_adapter = GmailAdapter.new(user)
  end

  def fetch_all_emails
    emails = []
    process_messages("INBOX", 500) do |message_info|
      emails << message_info
    end
    emails
  end

  def fetch_emails_in_date_range(start_date, end_date)
    start_date = Date.parse(start_date) unless start_date.is_a?(Date)
    end_date = Date.parse(end_date) unless end_date.is_a?(Date)
    query = "after:#{start_date.strftime("%Y/%m/%d")} before:#{end_date.strftime("%Y/%m/%d")}"
    emails = []
    process_messages("INBOX", 500, query) do |message_info|
      emails << message_info
    end
    emails
  end

  private

  attr_reader :gmail_adapter

  def process_messages(label_id, max_results, query = nil)
    page_token = nil
    loop do
      response = gmail_adapter.list_user_messages(label_id, max_results, page_token, query)
      break unless response.messages&.any?

      response.messages.each do |message|
        message_info = gmail_adapter.get_user_message(message.id)
        yield message_info
      end

      page_token = response.next_page_token
      break unless page_token
    end
  end
end
