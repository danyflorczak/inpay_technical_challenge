require "rails_helper"

RSpec.describe EmailRetrievalService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:gmail_adapter) { instance_double(GmailAdapter) }

  before do
    allow(GmailAdapter).to receive(:new).with(user).and_return(gmail_adapter)
  end

  describe "#fetch_all_emails" do
    let(:mock_message) { double("Message", id: "123") }
    let(:mock_response) { double("Response", messages: [mock_message], next_page_token: nil) }

    before do
      allow(gmail_adapter).to receive(:list_user_messages).and_return(mock_response)
      allow(gmail_adapter).to receive(:get_user_message).with(mock_message.id).and_return("EmailDetails")
    end

    it "fetches emails using GmailAdapter" do
      emails = service.fetch_all_emails
      expect(emails).to eq(["EmailDetails"])
    end
  end
end
