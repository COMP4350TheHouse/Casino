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

    let has_started = false;
    let horse_has_finished = false;
    const horseDivs = document.getElementsByClassName("race_horse");

    let index = 0;
    let finish_place = 1;

    horses.forEach(horse => {
      const horseImg = horseDivs[index];
      const ANIMATION_PAUSE_DELAY = 3000; // Matches the CSS transition time

      // Move Horse
      horseImg.style.left = Math.min(100, horse.position) * 0.90 + "%"; // Caps the position to 90

      if (horse.position >= 100) {
          setTimeout(function() {
            horseImg.style.animationPlayState = "paused";
            finish_place += 1;
          }, ANIMATION_PAUSE_DELAY);
          // The race has started and a horse has finished
          has_started = true;
          horse_has_finished = true;
      } else if (horse.position == 0) {
          horseImg.style.animationPlayState = "paused";
      } else {
          has_started = true;
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

        index += 1;
    });

    const race_track = document.getElementById("race_track");
    if (horse_has_finished) {
        race_track.style.animationPlayState = "paused";

        // Slow the running animations
        index = 0
        horses.forEach(horse => {
            const horseImg = horseDivs[index];
            horseImg.style.animationDuration = "1s";
            index += 1;
        });
    } else if (!has_started) {
        index = 0
        horses.forEach(horse => {
            const horseImg = horseDivs[index];
            horseImg.style.animationDuration = "0.1s";
            index += 1;
        });
        race_track.style.animationPlayState = "paused";
    } else {
        race_track.style.animationPlayState = "running";
    }

  }
});
