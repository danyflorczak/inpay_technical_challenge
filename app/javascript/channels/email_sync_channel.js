import consumer from "./consumer"

consumer.subscriptions.create({ channel: "EmailSyncChannel" }, {
  received(data) {
    if (data.status === "completed") {
      window.location.href = "/emails/dashboard?synced=true";
    }
  }
});
