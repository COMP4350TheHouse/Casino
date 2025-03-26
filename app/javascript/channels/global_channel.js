// Import the consumer instance from the channels to manage websockets
import consumer from "channels/consumer"

// Create a subscription to the "GlobalChannel" so all gamblers can confer with eachother
consumer.subscriptions.create("GlobalChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  // Callback function when a message is received from the server
  received(data) {
    if (document.getElementById('Global') == null) { return; }

    const MESSAGES = document.getElementById('Global');
    const MESSAGE  = document.createElement('p');

    MESSAGE.classList.add('chat-text');
    MESSAGE.innerHTML = data["body"];
    MESSAGES.insertBefore(MESSAGE, MESSAGES.firstChild);
  },

  // Send action on the server through Action Cable
  send: function() {
    return this.perform('send');
  }
});
