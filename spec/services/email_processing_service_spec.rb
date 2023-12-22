require "rails_helper"

RSpec.describe EmailProcessingService do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }
  let(:logger) { instance_spy(Logger) }

  before do
    allow(Rails).to receive(:logger).and_return(logger)
  end

  describe "#process_and_save_emails" do
    let(:sample_email_id) { "123" }
    let(:sample_email) do
      OpenStruct.new(
        id: sample_email_id,
        payload: OpenStruct.new(
          headers: [
            OpenStruct.new(name: "From", value: Faker::Internet.email),
            OpenStruct.new(name: "Subject", value: Faker::Lorem.sentence),
            OpenStruct.new(name: "Date", value: Faker::Time.backward(days: 14).rfc2822)
          ]
        )
      )
    end

    let(:parsed_email) do
      {
        gmail_id: sample_email_id,
        user_id: user.id,
        sender: sample_email.payload.headers.find { |h| h.name == "From" }.value,
        subject: sample_email.payload.headers.find { |h| h.name == "Subject" }.value,
        email_date: anything,
        email_datetime: anything
      }
    end

    before do
      allow(EmailParserService).to receive(:new).and_return(instance_double(EmailParserService, parse: parsed_email))
      allow(Email).to receive(:upsert_all)
    end

    context "when emails are processed successfully" do
      it "calls EmailParserService to parse emails" do
        service.process_and_save_emails([sample_email])
        expect(EmailParserService).to have_received(:new).with(sample_email, user).at_least(:once)
      end

      it "saves email records using upsert_all" do
        service.process_and_save_emails([sample_email])
        expect(Email).to have_received(:upsert_all).with([parsed_email], unique_by: :gmail_id)
      end

      it "returns a success response" do
        result = service.process_and_save_emails([sample_email])
        expect(result).to eq({success: true, message: "Successfully saved all mail records"})
      end
    end

    context "when there is an error saving emails" do
      before do
        allow(Email).to receive(:upsert_all).and_raise(ActiveRecord::RecordInvalid.new(Email.new))
      end

      it "logs an error" do
        service.process_and_save_emails([sample_email])
        expect(logger).to have_received(:error).with(/Error in EmailProcessingService/)
      end

      it "returns an error response" do
        result = service.process_and_save_emails([sample_email])
        expect(result).to eq({success: false, message: "Failed to save emails due to an invalid record"})
      end
    end
  end
end
