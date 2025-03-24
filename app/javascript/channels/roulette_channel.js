// Import the consumer instance from the channels to manage websockets
import consumer from "channels/consumer"

// Create a subscription to the "HorseRaceChannel" so all gamblers can confer with eachother within the roulette lobby only
consumer.subscriptions.create("RouletteChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  // Callback function when a message is received from the server
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
