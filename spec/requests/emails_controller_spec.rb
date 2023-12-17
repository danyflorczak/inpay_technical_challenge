require "rails_helper"

RSpec.describe EmailsController, type: :controller do
  let(:user) { create(:user) }
  let(:emails) { create_list(:email, 5, user: user) }

  before do
    sign_in user
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe "GET #index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #count" do
    context "when query is present" do
      it "assigns emails_count" do
        get :count, params: {q: {subject_cont: "test"}}
        expect(assigns(:emails_count)).not_to be_nil
      end
    end

    context "when query is not present" do
      it "does not assign emails_count" do
        get :count
        expect(assigns(:emails_count)).to be_nil
      end
    end
  end

  describe "GET #subjects" do
    context "when query is present" do
      it "responds successfully" do
        get :subjects, params: {q: {subject_cont: "test"}}
        expect(response).to be_successful
      end

      it "assigns subjects variable" do
        get :subjects, params: {q: {subject_cont: "test"}}
        expect(assigns(:subjects)).not_to be_nil
      end
    end

    context "when query is not present" do
      it "assigns an empty array to subjects" do
        get :subjects
        expect(assigns(:subjects)).to eq([])
      end
    end
  end

  describe "GET #stats" do
    it "assigns most_frequent_sender" do
      emails
      get :stats
      expect(assigns(:most_frequent_sender)).not_to be_nil
    end
  end
end
