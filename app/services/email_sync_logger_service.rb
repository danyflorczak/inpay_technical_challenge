# EmailSyncLoggerService is a service class responsible for logging the outcome
# of email synchronization processes. It provides a class method to log either
# a success or error message based on the result of the email sync operation.
#
# This service is typically used in conjunction with background jobs or services
# that handle email synchronization, allowing for consistent and centralized
# logging of these operations.
#
# @example Logging a successful email sync operation
#   result = { success: true, message: "All emails processed" }
#   EmailSyncLoggerService.log(user, result)
#
# @example Logging a failed email sync operation
#   result = { success: false, error: "API limit exceeded" }
#   EmailSyncLoggerService.log(user, result)
#
class EmailSyncLoggerService
  # Logs the result of an email synchronization process.
  # Based on the success or failure of the operation, logs an appropriate
  # message with the Rails logger.
  #
  # @param user [User] The user for whom the email sync process was performed.
  # @param result [Hash] A hash containing the result of the email sync operation.
  #                      Expected keys are :success and optionally :error.
  # @return [void]
  def self.log(user, result)
    user_id = user.id
    is_error = result[:error]
    message = is_error ? "Failed to process emails for user #{user_id}" :
                "Successfully processed emails for user #{user_id}"
    log_method = is_error ? :error : :info

    # Rails.logger is used to log the message. The logging level (:error or :info)
    # is determined based on whether the result indicates an error or success.
    Rails.logger.send(log_method, message)
  end
end
