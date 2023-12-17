class EmailSyncJob < ApplicationJob
  queue_as :default

  def perform(user, start_date = nil, end_date = nil)
    email_retrieval_service = EmailRetrievalService.new(user)
    emails = if start_date && end_date
      email_retrieval_service.fetch_emails_in_date_range(start_date, end_date)
    else
      email_retrieval_service.fetch_all_emails
    end
    email_processing_service = EmailProcessingService.new(user)
    result = email_processing_service.process_and_save_emails(emails)

    if result[:error]
      Rails.logger.error "Failed to process emails for user #{user.id}"
    else
      Rails.logger.info "Successfully processed emails for user #{user.id}"
      ActionCable.server.broadcast "email_sync_user_#{user.id}", {status: "completed"}
    end
  end
end
