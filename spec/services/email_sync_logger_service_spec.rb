require "rails_helper"

RSpec.describe EmailSyncLoggerService do
  describe ".log" do
    let(:user) { create(:user) }
    let(:logger) { instance_double(Logger) }

    before do
      allow(Rails).to receive(:logger).and_return(logger)
      allow(logger).to receive(:info)
      allow(logger).to receive(:error)
    end

    context "when result is successful" do
      let(:success_result) { {success: true} }

      it "logs a success message" do
        described_class.log(user, success_result)
        expect(logger).to have_received(:info).with("Successfully processed emails for user #{user.id}")
      end
    end

    context "when result is an error" do
      let(:error_result) { {error: "Some error"} }

      it "logs an error message" do
        described_class.log(user, error_result)
        expect(logger).to have_received(:error).with("Failed to process emails for user #{user.id}")
      end
    end
  end
end
