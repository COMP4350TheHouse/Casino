// Import the consumer instance from the channels to manage websockets
import consumer from "channels/consumer"

// Create a subscription to the "HorseRaceChannel" so all gamblers can confer with eachother within the horse racing lobby only
consumer.subscriptions.create("HorseRaceChatChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  // Callback function when a message is received from the server
  received(data) {
    if (document.getElementById('Horse Race') == null) { return; }

    const MESSAGES = document.getElementById('Horse Race');
    const MESSAGE  = document.createElement('p');

    MESSAGE.classList.add('chat-text');
    MESSAGE.innerHTML = data["body"];
    MESSAGES.insertBefore(MESSAGE, MESSAGES.firstChild);
  }
});
