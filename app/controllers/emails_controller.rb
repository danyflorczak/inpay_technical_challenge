class EmailsController < ApplicationController
  def index
  end

  def count
    @q = current_user.emails.ransack(params[:q])
    @emails_count = params[:q] ? @q.result.count : nil
  end

  def subjects
    @q = current_user.emails.ransack(params[:q])
    @subjects = params[:q] ? @q.result.pluck(:subject) : []
  end

  def stats
    @most_frequent_sender = current_user.emails.group(:sender).order("count_sender desc").count("sender").first
  end
end
