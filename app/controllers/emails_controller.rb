# The EmailsController is responsible for managing various email-related actions
# in the application. It includes actions for displaying email statistics,
# initiating email synchronization jobs, and handling user queries for email counts
# and subjects.
#
class EmailsController < ApplicationController
  before_action :set_ransack_query, only: [:count, :subjects]

  # Displays the main index page for emails. Typically, this action would
  # render an overview or a dashboard related to emails.
  #
  def index
  end

  # Renders the dashboard page. If the `synced` parameter is present, it
  # sets a success notice for the email synchronization.
  #
  def dashboard
    flash[:notice] = t("email_sync.success") if params[:synced]
  end

  # Counts the number of emails based on the current search criteria.
  # This action uses Ransack for searching and filtering.
  #
  # @raise [StandardError] If there is an error in counting emails.
  #
  def count
    @emails_count = search_result&.count
  rescue => e
    handle_error(e, "counting emails")
  end

  # Retrieves and lists the subjects of emails based on the current
  # search criteria set by Ransack.
  #
  # @raise [StandardError] If there is an error in retrieving subjects.
  #
  def subjects
    @subjects = search_result&.pluck(:subject) || []
  rescue => e
    handle_error(e, "retrieving subjects")
  end

  # Calculates and displays statistics related to emails, such as the most
  # frequent sender.
  #
  # @raise [StandardError] If there is an error in retrieving stats.
  #
  def stats
    @most_frequent_sender = current_user.emails.group(:sender)
      .order("count_sender desc")
      .count("sender").first
  rescue => e
    handle_error(e, "retrieving stats")
  end

  # Initiates an asynchronous job to synchronize emails.
  #
  # @raise [StandardError] If there is an error in syncing emails.
  #
  def sync_emails
    EmailSyncJob.perform_later(current_user.id)
  rescue => e
    handle_error(e, "syncing emails")
  end

  # Prepares for syncing emails with a specified date range. The actual
  # implementation details would be added as needed.
  #
  def sync_emails_with_date_range
  end

  # Performs an asynchronous job to synchronize emails within a specified
  # date range.
  #
  # @raise [StandardError] If there is an error in syncing emails for the date range.
  #
  def perform_sync_with_date_range
    EmailSyncJob.perform_later(current_user.id, params[:start_date], params[:end_date])
    redirect_to sync_emails_emails_path
  rescue => e
    handle_error(e, "syncing emails for date range")
  end

  private

  # Sets up the Ransack query object based on the current user's emails and
  # the provided search parameters.
  #
  def set_ransack_query
    @q = current_user.emails.ransack(params[:q])
  end

  # Handles errors that occur within controller actions.
  # Sets a flash error message and redirects to the dashboard.
  #
  # @param exception [StandardError] The exception object caught in rescue blocks.
  # @param action [String] Description of the action during which the error occurred.
  #
  def handle_error(exception, action)
    flash[:error] = "Error #{action}: #{exception.message}"
    redirect_to dashboard_emails_path
  end

  # Executes the Ransack search query and returns the result.
  # Used by actions that involve searching and filtering emails.
  #
  # @return [Ransack::Result] The result of the Ransack search query.
  #
  def search_result
    params[:q] && @q.result
  end
end
