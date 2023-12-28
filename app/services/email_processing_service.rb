# EmailProcessingService is responsible for processing a batch of email data
# and saving it into the database. It includes parsing the email data,
# building records, and handling their storage. This service ensures that
# all email data is processed and saved atomically.
#
# @example Instantiate the service and process emails
#   processing_service = EmailProcessingService.new(user)
#   result = processing_service.process_and_save_emails(emails)
#
class EmailProcessingService
  # Initializes the EmailProcessingService with a given user.
  #
  # @param user [User] The user associated with the email records being processed.
  def initialize(user)
    @user = user
  end

  # Processes a collection of email data and saves it to the database.
  # The method handles transactional saving of email records and provides
  # appropriate responses based on the outcome.
  #
  # @param emails [Array<Object>] An array of email objects to be processed.
  # @return [Hash] A hash indicating the success or failure of the operation.
  # @raise [ActiveRecord::RecordInvalid] If saving an email record fails due to validation.
  # @raise [StandardError] For any unexpected errors during processing.
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

  # Builds email record objects from a collection of email data.
  # It uses EmailParserService to parse individual email data.
  #
  # @param emails [Array<Object>] An array of email objects to be processed.
  # @return [Array<Hash>] An array of email record hashes ready to be saved.
  def build_email_records(emails)
    emails.map { |email| EmailParserService.new(email, user).parse }.compact
  end

  # Saves an array of email record hashes to the database if not empty.
  # This method delegates to the class method `save_email_records`.
  #
  # @param email_records [Array<Hash>] An array of email record hashes.
  def save_email_records_if_present(email_records)
    self.class.save_email_records(email_records) unless email_records.empty?
  end

  # Class method to save email records to the database using `upsert_all`.
  # It ensures no duplicate records are created based on the `gmail_id`.
  #
  # @param email_records [Array<Hash>] An array of email record hashes.
  def self.save_email_records(email_records)
    Email.upsert_all(email_records, unique_by: :gmail_id)
  end

  # Logs an error message with an optional type.
  #
  # @param error [StandardError] The error object to be logged.
  # @param type [String] A string describing the type of error (default: "Error").
  def log_error(error, type = "Error")
    Rails.logger.error "#{type} in EmailProcessingService for user #{user.id}: #{error.message}"
  end

  # Constructs a success response hash.
  #
  # @return [Hash] A hash representing a successful operation.
  def success_response
    {success: true, message: "Successfully saved all mail records"}
  end

  # Constructs a failure response hash with a provided message.
  #
  # @param message [String] The error message to include in the response.
  # @return [Hash] A hash representing a failed operation.
  def failure_response(message)
    {success: false, message: message}
  end
end
