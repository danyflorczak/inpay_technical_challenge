class EmailsController < ApplicationController
  before_action :set_search_query, only: [:count, :subjects]

  def index
  end

  def count
    @emails_count = params[:q] ? @search_query.result.count : nil
  end

  def subjects
    @subjects = params[:q] ? @search_query.result.pluck(:subject) : []
  end

  def stats
    @most_frequent_sender = current_user.emails.group(:sender).order("count_sender desc").count("sender").first
  end

  private

  def set_search_query
    @search_query = current_user.emails.ransack(params[:q])
  end
end
