import consumer from "channels/consumer"

consumer.subscriptions.create("HorseRaceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const horses = data.message;

    horses.forEach(horse => {
      const horseDiv = document.getElementById("horse" + horse.id);
      const horseImg = horseDiv.querySelector("div");
      // Move Horse
      horseImg.style.left = Math.min(100, horse.position) + "%";
      // Stop Horse if its done
      // NEEDS TO BE CHANGED AFTER 3S
      //

      if (horse.position >= 100) {
          setTimeout(function() {
            horseImg.style.animationPlayState = "paused";

            // Add wager payout here...
          }, 3000);
      } else {
        horseImg.style.animationPlayState = "running";
      }

      //let horseCardDiv = document.getElementById("horse" + horse.id + "Card");
      //horseCardDiv = horse.bet_card;

      /*
      // Update betting odds
      const horseCardDiv = document.getElementById("horse" + horse.id + "Card");
      const kinds = ["straight", "place", "show"];

      kinds.forEach(kind => {
        const kindDiv = horseCardDiv.querySelector("#" + kind + "Form");
        const payout  = kindDiv.querySelector("#payout");
        payout.innerText = horse[kind + "_odds"];
      });
      */
    });
  }
});
