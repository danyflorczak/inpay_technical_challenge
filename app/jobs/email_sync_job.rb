# EmailSyncJob is an ActiveJob used for synchronizing emails from an external service.
# This job fetches emails for a given user, optionally within a specified date range,
# processes them, and then broadcasts the result. It's designed to run asynchronously
# to avoid blocking the main thread of the application.
#
# The job handles fetching emails through the EmailRetrievalService and processes
# them using EmailProcessingService. It also logs the process and broadcasts
# the result using EmailSyncLoggerService and EmailSyncBroadcasterService respectively.
#
# @example Enqueue the job for a user without a date range
#   EmailSyncJob.perform_later(user.id)
# @example Enqueue the job for a user with a date range
#   EmailSyncJob.perform_later(user.id, '2023-01-01', '2023-01-31')
#
class EmailSyncJob < ApplicationJob
  queue_as :default

  # Performs the job of synchronizing emails.
  # It finds the user, fetches their emails (optionally within a date range),
  # processes the emails, and then broadcasts the result.
  #
  # @param user_id [Integer] The ID of the user for whom to synchronize emails.
  # @param start_date [String, nil] The start date for email retrieval, if applicable.
  # @param end_date [String, nil] The end date for email retrieval, if applicable.
  #
  def perform(user_id, start_date = nil, end_date = nil)
    user = User.find(user_id)
    emails = EmailRetrievalService.new(user).fetch_emails(start_date, end_date)
    process_and_broadcast_result(user, emails)
  end

  private

  # Processes the fetched emails and broadcasts the result.
  # This method is used internally by the perform method.
  #
  # @param user [User] The user for whom the emails are being processed.
  # @param emails [Array] An array of email objects to be processed.
  # @return [void]
  #
  def process_and_broadcast_result(user, emails)
    result = EmailProcessingService.new(user).process_and_save_emails(emails)
    EmailSyncLoggerService.log(user, result)
    EmailSyncBroadcasterService.broadcast(user) if result[:success]
  end
end
