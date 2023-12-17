require "rails_helper"

RSpec.describe GmailAdapter do
  subject(:adapter) { described_class.new(user) }

  let(:user) { build(:user, email: Faker::Internet.email, token: Faker::Crypto.md5, refresh_token: Faker::Crypto.md5) }
  let(:gmail_service) { instance_double(Google::Apis::GmailV1::GmailService) }

  before do
    allow(Google::Apis::GmailV1::GmailService).to receive(:new).and_return(gmail_service)
    allow(gmail_service).to receive(:authorization=)
    allow(user).to receive(:update)
  end

  describe "#list_user_messages" do
    let(:label_id) { "INBOX" }
    let(:max_results) { 10 }
    let(:page_token) { "token123" }

    context "when API call is successful" do
      it "returns messages" do
        allow(gmail_service).to receive(:list_user_messages).and_return("messages")
        expect(adapter.list_user_messages(label_id, max_results, page_token)).to eq("messages")
      end
    end
  end

  describe "#get_user_message" do
    let(:message_id) { "message123" }

    context "when API call is successful" do
      it "returns the message" do
        allow(gmail_service).to receive(:get_user_message).and_return("message")
        expect(adapter.get_user_message(message_id)).to eq("message")
      end
    end
  end

  describe "handling authorization errors" do
    let(:error) { Google::Apis::AuthorizationError.new("Token expired") }

    before do
      allow(gmail_service).to receive(:list_user_messages).and_raise(error)
    end

    it "attempts to refresh the token and retry" do
      allow(adapter).to receive(:refresh_token!).and_raise(GmailAdapter::AuthorizationError)
      expect { adapter.list_user_messages("INBOX", 10, nil) }.to raise_error(GmailAdapter::AuthorizationError)
    end
  end
end
