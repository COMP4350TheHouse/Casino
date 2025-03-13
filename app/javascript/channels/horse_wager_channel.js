import consumer from "channels/consumer"

consumer.subscriptions.create("HorseWagerChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to Horse Wager Channel")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected to Horse Wager Channel")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    console.log("GETTING THE WAGER DATA");

    let tbodyRef = document.getElementById('horse_wager_payout_body');

    let row = tbodyRef.insertRow();
    let cell1 = row.insertCell(0);
    let cell2 = row.insertCell(1);
    let cell3 = row.insertCell(2);

    cell1.innerHTML = "Test"
    cell2.innerHTML = "Test"
    cell3.innerHTML = "Test"
  }
});
