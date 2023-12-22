class EmailSyncBroadcasterService
  def self.broadcast(user)
    ActionCable.server.broadcast "email_sync_user_#{user.id}", {status: "completed"}
  end
end
