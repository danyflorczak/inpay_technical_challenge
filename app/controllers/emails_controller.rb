class EmailsController < ApplicationController
  def index
  end

  def dashboard
    flash[:notice] = "Email sync was successful." if params[:synced]
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

  def sync_emails
    if user_signed_in?
      EmailSyncJob.perform_later(current_user)
    end
  end

  def sync_emails_with_date_range
  end

  def perform_sync_with_date_range
    start_date = params[:start_date]
    end_date = params[:end_date]
    EmailSyncJob.perform_later(current_user, start_date, end_date)
    redirect_to sync_emails_emails_path
  end
end
