require "rails_helper"

RSpec.describe EmailSyncJob do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:email_retrieval_service) { instance_double(EmailRetrievalService) }
  let(:email_processing_service) { instance_double(EmailProcessingService, process_and_save_emails: {success: true, message: "Successfully saved all mail records"}) }
  let(:emails) { [double("email")] }

  before do
    allow(User).to receive(:find).with(user.id).and_return(user)
    allow(EmailRetrievalService).to receive(:new).with(user).and_return(email_retrieval_service)
    allow(EmailProcessingService).to receive(:new).with(user).and_return(email_processing_service)
    allow(email_retrieval_service).to receive(:fetch_emails).and_return(emails)
    allow(EmailSyncLoggerService).to receive(:log)
    allow(EmailSyncBroadcasterService).to receive(:broadcast)
  end

  describe "#perform" do
    let(:start_date) { "2023-01-01" }
    let(:end_date) { "2023-01-31" }

    it "fetches emails without a date range" do
      perform_enqueued_jobs { described_class.perform_later(user.id) }
      expect(email_retrieval_service).to have_received(:fetch_emails).with(nil, nil)
    end

    it "fetches emails within a date range" do
      perform_enqueued_jobs { described_class.perform_later(user.id, start_date, end_date) }
      expect(email_retrieval_service).to have_received(:fetch_emails).with(start_date, end_date)
    end

    it "processes the fetched emails" do
      perform_enqueued_jobs { described_class.perform_later(user.id) }
      expect(email_processing_service).to have_received(:process_and_save_emails).with(emails)
    end

    context "when email processing is successful" do
      it "broadcasts a completion status" do
        perform_enqueued_jobs { described_class.perform_later(user.id) }
        expect(EmailSyncBroadcasterService).to have_received(:broadcast).with(user)
      end
    end
  end
end
