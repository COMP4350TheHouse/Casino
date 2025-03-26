// Import the consumer instance from the channels to manage websockets
import consumer from "channels/consumer"

// Create a subscription to the "HorseRaceChannel" so all gamblers view their wagers, available horses to bet on, and payouts
consumer.subscriptions.create("HorseWagerChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to Horse Wager Channel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected to Horse Wager Channel")
  },

  // Callback function when a message is received from the server
  received(data) {
    if (document.getElementById('horse_wager_payout_body') == null) { return; }

    let message = data.message;
    let tbodyRef = document.getElementById('horse_wager_payout_body');

    let row = tbodyRef.insertRow();
    let cell1 = row.insertCell(0);
    let cell2 = row.insertCell(1);
    let cell3 = row.insertCell(2);

    // On the Table on the Horse Race Webpage, the order is 1. Horse Name, 2. Bet Type, 3. Payout
    cell1.innerHTML = message.horse_name;
    cell2.innerHTML = message.bet_type;
    cell3.innerHTML = message.payout;
  }
});
