class EmailSyncJob < ApplicationJob
  queue_as :default

  def perform(user_id, start_date = nil, end_date = nil)
    user = User.find(user_id)
    emails = EmailRetrievalService.new(user).fetch_emails(start_date, end_date)
    process_and_broadcast_result(user, emails)
  end

  private

  def process_and_broadcast_result(user, emails)
    result = EmailProcessingService.new(user).process_and_save_emails(emails)
    EmailSyncLoggerService.log(user, result)
    EmailSyncBroadcasterService.broadcast(user) if result[:success]
  end
end
