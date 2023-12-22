class EmailsController < ApplicationController
  before_action :set_ransack_query, only: [:count, :subjects]

  def index
  end

  def dashboard
    flash[:notice] = t("email_sync.success") if params[:synced]
  end

  def count
    @emails_count = search_result&.count
  rescue => e
    handle_error(e, "counting emails")
  end

  def subjects
    @subjects = search_result&.pluck(:subject) || []
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
    EmailSyncJob.perform_later(current_user.id)
  rescue => e
    handle_error(e, "syncing emails")
  end

  def sync_emails_with_date_range
  end

  def perform_sync_with_date_range
    EmailSyncJob.perform_later(current_user.id, params[:start_date], params[:end_date])
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

  def search_result
    params[:q] && @q.result
  end
end
