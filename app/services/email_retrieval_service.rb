require "date"
require "concurrent-ruby"

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
    emails = Concurrent::Array.new

    threads = fetch_pages(query).map do |messages|
      Thread.new do
        process_messages(messages, emails)
      end
    end

    threads.each(&:join)
    emails
  end

  def fetch_pages(query)
    pages = []
    page_token = nil

    loop do
      response = gmail_adapter.list_user_messages(INBOX_LABEL, MAX_RESULTS, page_token, query)
      break unless (messages = response.messages)&.any?

      pages << messages
      page_token = response.next_page_token
      break unless page_token
    end

    pages
  end

  def process_messages(messages, emails)
    messages.each do |message|
      email = gmail_adapter.get_user_message(message.id)
      emails << email if email
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
