class EmailSyncLoggerService
  def self.log(user, result)
    user_id = user.id
    is_error = result[:error]
    message = is_error ? "Failed to process emails for user #{user_id}" :
                         "Successfully processed emails for user #{user_id}"
    log_method = is_error ? :error : :info

    Rails.logger.send(log_method, message)
  end
end
