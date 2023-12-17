class EmailsController < ApplicationController
  before_action :set_ransack_query, only: [:count, :subjects]

  def index
  end

  def dashboard
    flash[:notice] = "Email sync was successful." if params[:synced]
  end

  def count
    @emails_count = params[:q] ? @q.result.count : nil
  rescue => e
    handle_error(e, "counting emails")
  end

  def subjects
    @subjects = params[:q] ? @q.result.pluck(:subject) : []
  rescue => e
    handle_error(e, "retrieving subjects")
  end

  def stats
    @most_frequent_sender = current_user.emails.group(:sender)
      .order("count_sender desc")
      .count("sender").first
  rescue => e
    handle_error(e, "retrieving stats")
  end

  def sync_emails
    if user_signed_in?
      begin
        EmailSyncJob.perform_later(current_user)
      rescue => e
        handle_error(e, "syncing emails")
      end
    end
  end

  def sync_emails_with_date_range
  end

  def perform_sync_with_date_range
    EmailSyncJob.perform_later(current_user, params[:start_date], params[:end_date])
    redirect_to sync_emails_emails_path
  rescue => e
    handle_error(e, "syncing emails for date range")
  end

  private

  def set_ransack_query
    @q = current_user.emails.ransack(params[:q])
  end

  def handle_error(exception, action)
    flash[:error] = "Error #{action}: #{exception.message}"
    redirect_to dashboard_emails_path
  end
end
