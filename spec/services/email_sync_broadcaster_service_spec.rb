require "rails_helper"

RSpec.describe EmailSyncBroadcasterService do
  describe ".broadcast" do
    let(:user) { create(:user) }
    let(:channel) { "email_sync_user_#{user.id}" }
    let(:broadcast_data) { {status: "completed"} }

    before do
      allow(ActionCable.server).to receive(:broadcast)
    end

    it "broadcasts a message to the correct channel" do
      described_class.broadcast(user)
      expect(ActionCable.server).to have_received(:broadcast).with(channel, broadcast_data)
    end
  end
end
