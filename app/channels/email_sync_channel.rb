class EmailSyncChannel < ApplicationCable::Channel
  def subscribed
    stream_from "email_sync_user_#{current_user.id}"
  end
end
