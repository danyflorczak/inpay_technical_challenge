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

  def fetch_last_email
    emails = []
    last_message = process_last_message("INBOX")
    emails << last_message if last_message
    emails
  end

  private

  attr_reader :gmail_adapter

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

  def process_last_message(label_id)
    response = gmail_adapter.list_user_messages(label_id, 1, nil)
    if response.messages&.any?
      message_id = response.messages.first.id
      gmail_adapter.get_user_message(message_id)
    end
  end
end
