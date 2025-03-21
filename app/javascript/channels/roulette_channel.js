import consumer from "channels/consumer"

consumer.subscriptions.create("RouletteChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    if (document.getElementById('Roulette') == null) {
      return;
    }

    const messages = document.getElementById('Roulette');
    const message  = document.createElement('p');

    message.classList.add('chat-text');
    message.innerHTML = data["body"];
    messages.insertBefore(message, messages.firstChild);
  }
});
