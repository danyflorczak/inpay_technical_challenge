class EmailProcessingService
  def initialize(user)
    @user = user
  end

  def process_and_save_emails(emails)
    ActiveRecord::Base.transaction do
      email_records = build_email_records(emails)
      save_email_records_if_present(email_records)
    end
    success_response
  rescue ActiveRecord::RecordInvalid => e
    log_error(e)
    failure_response("Failed to save emails due to an invalid record")
  rescue => e
    log_error(e, "Unexpected")
    failure_response("Unexpected error occurred")
  end

  private

  attr_reader :user

  def build_email_records(emails)
    emails.map { |email| EmailParserService.new(email, user).parse }.compact
  end

  def save_email_records_if_present(email_records)
    self.class.save_email_records(email_records) unless email_records.empty?
  end

  def self.save_email_records(email_records)
    Email.upsert_all(email_records, unique_by: :gmail_id)
  end

  def log_error(error, type = "Error")
    Rails.logger.error "#{type} in EmailProcessingService for user #{user.id}: #{error.message}"
  end

  def success_response
    {success: true, message: "Successfully saved all mail records"}
  end

  def failure_response(message)
    {success: false, message: message}
  end
end
