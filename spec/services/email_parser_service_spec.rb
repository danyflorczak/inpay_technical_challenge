require "rails_helper"

RSpec.describe EmailParserService do
  let(:user) { create(:user) }
  let(:message_info) do
    OpenStruct.new(
      id: "12345",
      payload: OpenStruct.new(
        headers: [
          OpenStruct.new(name: "From", value: "sender@example.com"),
          OpenStruct.new(name: "Subject", value: "Test Subject"),
          OpenStruct.new(name: "Date", value: "Mon, 21 Dec 2023 12:00:00 +0000")
        ]
      )
    )
  end
  let(:service) { described_class.new(message_info, user) }

  describe "#parse" do
    context "when the message info is valid" do
      it "parses and returns the email details" do
        result = service.parse
        expect(result).to eq({
          gmail_id: "12345",
          sender: "sender@example.com",
          subject: "Test Subject",
          email_date: Date.parse("2023-12-21"),
          email_datetime: DateTime.parse("Mon, 21 Dec 2023 12:00:00 +0000"),
          user_id: user.id
        })
      end
    end

    context "when the email date is in an invalid format" do
      before do
        message_info.payload.headers.find { |h| h.name == "Date" }.value = "invalid date"
        allow(Rails.logger).to receive(:warn)
      end

      it "returns nil for invalid date format" do
        expect(service.parse).to be_nil
      end

      it "logs a warning for invalid date format" do
        service.parse
        expect(Rails.logger).to have_received(:warn).with(/Invalid date format in email: 12345/)
      end
    end
  end
end
