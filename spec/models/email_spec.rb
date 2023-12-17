require "rails_helper"

RSpec.describe Email do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "ransackable attributes" do
    subject { described_class.ransackable_attributes }

    it { is_expected.to include("sender", "email_date", "user_id", "subject") }
  end
end
