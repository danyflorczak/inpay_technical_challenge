# EmailSyncBroadcasterService is responsible for broadcasting updates related
# to the email synchronization process over an ActionCable channel. It provides
# a class method to send a broadcast message indicating the completion status
# of the email synchronization for a specific user.
#
# This service is typically used in conjunction with background jobs that
# perform email synchronization, enabling real-time updates to the user's client
# about the status of the sync process.
#
# @example Broadcasting a completion message for a user
#   EmailSyncBroadcasterService.broadcast(user)
#
class EmailSyncBroadcasterService
  # Broadcasts a message over an ActionCable channel to a specific user
  # indicating the completion of the email synchronization process.
  #
  # This method constructs a unique channel name based on the user's ID and
  # sends a message with the synchronization status.
  #
  # @param user [User] The user for whom the broadcast message is intended.
  # @return [void]
  def self.broadcast(user)
    # The channel name is dynamically constructed using the user's ID to ensure
    # that the broadcast is targeted to the correct user.
    # The message payload includes the synchronization status.
    ActionCable.server.broadcast "email_sync_user_#{user.id}", {status: "completed"}
  end
end
