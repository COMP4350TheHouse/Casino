import consumer from "channels/consumer"

consumer.subscriptions.create("HorseRaceChatChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
      if (document.getElementById('Horse Race') == null) {
        return;
      }
    // Called when there's incoming data on the websocket for this channel
    const messages = document.getElementById('Horse Race');
    const message  = document.createElement('p');

    message.classList.add('chat-text');
    message.innerHTML = data["body"];
    messages.insertBefore(message, messages.firstChild);
  }
});
