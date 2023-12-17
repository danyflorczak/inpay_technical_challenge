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

    context "when emails are processed successfully" do
      before do
        allow(Email).to receive(:insert_all)
        allow(Email).to receive(:where).and_return(Email.none)
      end

      it "builds email records correctly" do
        expect(service.send(:build_email_record, sample_email)).to include(
          gmail_id: sample_email_id,
          user_id: user.id,
          sender: anything,
          subject: anything,
          email_date: anything,
          email_datetime: anything
        )
      end

      it "saves email records" do
        service.process_and_save_emails([sample_email])
        expect(Email).to have_received(:insert_all)
      end

      it "returns success message" do
        result = service.process_and_save_emails([sample_email])
        expect(result).to eq({success: "Successfully saved all mail records"})
      end
    end

    context "when there are duplicate emails" do
      let(:existing_email) { create(:email, gmail_id: sample_email_id, user: user) }

      before do
        existing_email
      end

      it "does not re-save duplicate records" do
        expect {
          service.process_and_save_emails([sample_email, sample_email])
        }.not_to change(Email, :count)
      end
    end

    context "when there is an error saving emails" do
      before do
        allow(Email).to receive(:insert_all).and_raise(ActiveRecord::RecordInvalid.new(Email.new))
      end

      it "logs an error" do
        service.process_and_save_emails([sample_email])
        expect(logger).to have_received(:error).with(/Error in EmailProcessingService/)
      end

      it "returns error message" do
        result = service.process_and_save_emails([sample_email])
        expect(result).to eq({error: "Failed to save emails"})
      end
    end
  end
end
