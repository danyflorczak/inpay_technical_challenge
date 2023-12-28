# EmailSyncChannel is an Action Cable channel that streams real-time updates
# to the client about the email synchronization process. It establishes a WebSocket
# connection for each subscribed user and streams data specifically related to
# that user's email synchronization status.
#
# The channel is uniquely named for each user to ensure that updates are
# broadcast only to the appropriate subscriber.
#
# @example Subscribe to the channel in a client-side JavaScript
#   consumer.subscriptions.create("EmailSyncChannel", {
#     received(data) {
#       // handle received data
#     }
#   });
#
class EmailSyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "email_sync_user_#{current_user.id}"
  end
end
