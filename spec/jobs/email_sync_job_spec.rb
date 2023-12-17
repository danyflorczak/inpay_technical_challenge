require "rails_helper"

RSpec.describe EmailSyncJob do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:email_retrieval_service) { instance_double(EmailRetrievalService) }
  let(:email_processing_service) { instance_double(EmailProcessingService) }
  let(:emails) { [double("email")] }

  before do
    allow(EmailRetrievalService).to receive(:new).with(user).and_return(email_retrieval_service)
    allow(EmailProcessingService).to receive(:new).with(user).and_return(email_processing_service)
  end

  describe "#perform" do
    context "when no date range is provided" do
      before do
        allow(email_retrieval_service).to receive(:fetch_all_emails).and_return(emails)
        allow(email_processing_service).to receive(:process_and_save_emails).with(emails).and_return({success: "Successfully saved all mail records"})
      end

      it "fetches all emails" do
        perform_enqueued_jobs { described_class.perform_later(user) }
        expect(email_retrieval_service).to have_received(:fetch_all_emails)
      end

      it "processes the fetched emails" do
        perform_enqueued_jobs { described_class.perform_later(user) }
        expect(email_processing_service).to have_received(:process_and_save_emails).with(emails)
      end
    end

    context "when a date range is provided" do
      let(:start_date) { "2023-01-01" }
      let(:end_date) { "2023-01-31" }

      before do
        allow(email_retrieval_service).to receive(:fetch_emails_in_date_range).with(start_date, end_date).and_return(emails)
        allow(email_processing_service).to receive(:process_and_save_emails).with(emails).and_return({success: "Successfully saved all mail records"})
      end

      it "fetches emails within the date range" do
        perform_enqueued_jobs { described_class.perform_later(user, start_date, end_date) }
        expect(email_retrieval_service).to have_received(:fetch_emails_in_date_range).with(start_date, end_date)
      end

      it "processes the fetched emails" do
        perform_enqueued_jobs { described_class.perform_later(user, start_date, end_date) }
        expect(email_processing_service).to have_received(:process_and_save_emails).with(emails)
      end
    end

    context "when email processing fails" do
      before do
        allow(email_retrieval_service).to receive(:fetch_all_emails).and_return(emails)
        allow(email_processing_service).to receive(:process_and_save_emails).with(emails).and_return({error: "Failed to save emails"})
      end

      it "logs an error" do
        allow(Rails.logger).to receive(:error)
        perform_enqueued_jobs { described_class.perform_later(user) }
        expect(Rails.logger).to have_received(:error).with("Failed to process emails for user #{user.id}")
      end
    end

    context "when email processing is successful" do
      before do
        allow(email_retrieval_service).to receive(:fetch_all_emails).and_return(emails)
        allow(email_processing_service).to receive(:process_and_save_emails).with(emails).and_return({success: "Successfully saved all mail records"})
      end

      it "broadcasts a completion status" do
        allow(ActionCable.server).to receive(:broadcast)
        perform_enqueued_jobs { described_class.perform_later(user) }
        expect(ActionCable.server).to have_received(:broadcast).with("email_sync_user_#{user.id}", {status: "completed"})
      end
    end
  end
end
