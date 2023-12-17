require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many(:emails).dependent(:destroy) }
  end

  describe ".from_omniauth" do
    let(:access_token) do
      OpenStruct.new(
        provider: "google_oauth2",
        uid: "123456789",
        info: OpenStruct.new(email: Faker::Internet.email),
        credentials: OpenStruct.new(
          token: Faker::Crypto.md5,
          refresh_token: Faker::Crypto.md5
        )
      )
    end

    context "when processing an OAuth access token" do
      before { described_class.from_omniauth(access_token) }

      let(:user) { described_class.last }

      it "creates a new user" do
        expect(described_class.count).to eq(1)
      end

      it "sets the provider correctly" do
        expect(user.provider).to eq(access_token.provider)
      end

      it "sets the uid correctly" do
        expect(user.uid).to eq(access_token.uid)
      end

      it "sets the email correctly" do
        expect(user.email).to eq(access_token.info.email)
      end

      it "sets the token correctly" do
        expect(user.token).to eq(access_token.credentials.token)
      end

      it "sets the refresh token correctly" do
        expect(user.refresh_token).to eq(access_token.credentials.refresh_token)
      end
    end
  end
end
