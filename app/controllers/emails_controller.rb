class EmailsController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = current_user
    @emails = @user.emails
  end
end
