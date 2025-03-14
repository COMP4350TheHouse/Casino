import consumer from "channels/consumer"

consumer.subscriptions.create("HorseRaceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    const horses = data.message.horses;
    const resetting = data.message.resetting;

    const ANIMATION_PAUSE_DELAY = 3000; // Matches the CSS transition time
    const POSITION_WHEN_BETS_CLOSE = 70;

    let has_started = false;
    let horse_has_finished = false;
    let is_betting_closed = false;

    const horseDivs = document.getElementsByClassName("race_horse");

    let index = 0;
    let finish_place = 1;

    horses.forEach(horse => {
      const horseImg = horseDivs[index];
      const ANIMATION_PAUSE_DELAY = 3000; // Matches the CSS transition time

      if (horse.position >= POSITION_WHEN_BETS_CLOSE) {
          is_betting_closed = true;
      }

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

      index += 1;
    });

    const race_track = document.getElementById("race_track");

    // Betting is closed
    if (is_betting_closed) {
        console.log("Bets closed");
        document.getElementById("main_betting_menu").style.visibility = "hidden";
        document.getElementById("horse_wager_placed_div").style.visibility = "hidden";

        //
        document.getElementById("horse_wager_payout_div").style.visibility = "visible";
    } else {
    // Betting is not closed
        console.log("Bets open");
        document.getElementById("main_betting_menu").style.visibility = "visible";
        document.getElementById("horse_wager_placed_div").style.visibility = "visible";

        document.getElementById("horse_wager_payout_div").style.visibility = "hidden";
    }

    if (resetting) {
        // Clear the tables
        document.getElementById("horse_wager_placed_body").innerHTML = "";

        document.getElementById("horse_wager_payout_body").innerHTML = "";

        // Move the track back so it looks less janky
        race_track.style.animationPlayState = "running";
        setTimeout(function() {
          race_track.style.animationPlayState = "paused";
        }, ANIMATION_PAUSE_DELAY);
    }

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
    } else {
        race_track.style.animationPlayState = "running";
    }
  }
});
