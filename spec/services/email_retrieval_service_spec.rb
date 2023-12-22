require "rails_helper"

RSpec.describe EmailRetrievalService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:gmail_adapter) { instance_double(GmailAdapter) }

  before do
    allow(GmailAdapter).to receive(:new).with(user).and_return(gmail_adapter)
  end

  describe "#fetch_emails" do
    let(:mock_message) { double("Message", id: "123") }
    let(:mock_response) { double("Response", messages: [mock_message], next_page_token: nil) }
    let(:start_date) { "2023-01-01" }
    let(:end_date) { "2023-01-31" }
    let(:formatted_query) { "after:2023/01/01 before:2023/01/31" }

    context "when fetching all emails" do
      before do
        allow(gmail_adapter).to receive(:list_user_messages).with("INBOX", 500, nil, nil).and_return(mock_response)
        allow(gmail_adapter).to receive(:get_user_message).with(mock_message.id).and_return("EmailDetails")
      end

      it "fetches all emails" do
        emails = service.fetch_emails
        expect(emails).to eq(["EmailDetails"])
      end
    end

    context "when fetching emails in date range" do
      before do
        allow(gmail_adapter).to receive(:list_user_messages).with("INBOX", 500, nil, formatted_query).and_return(mock_response)
        allow(gmail_adapter).to receive(:get_user_message).with(mock_message.id).and_return("EmailDetails")
      end

      it "fetches emails within the specified date range" do
        emails = service.fetch_emails(start_date, end_date)
        expect(emails).to eq(["EmailDetails"])
      end
    end
  end
end
