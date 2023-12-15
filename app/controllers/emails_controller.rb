class EmailsController < ApplicationController
  before_action :authenticate_user!
  def index
    @user = current_user
    @q = @user.emails.ransack(params[:q])
    @emails = @q.result(distinct: true)
  end
end
