import consumer from "channels/consumer"

consumer.subscriptions.create("HorseRaceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
<<<<<<< HEAD
    const horses = data.message.horses;
    const resetting = data.message.resetting;
    const time_to_next_race = data.message.time_to_next_race;



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

    // Conditionally renders the betting open / closed menus
    if (is_betting_closed) {
        document.getElementById("horse_betting_div").style.visibility = "hidden";
        document.getElementById("horse_closed_betting_div").style.visibility = "visible";
    } else {
        document.getElementById("horse_betting_div").style.visibility = "visible";
        document.getElementById("horse_closed_betting_div").style.visibility = "hidden";
    }

    // Resets the race (Moves the camera, clears the tables)
    // Horses are slide back using the same mechanism that moves them forward
    // Countdown timer is set by the data passed, so it does not need a reset
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

    /// Countdown clock functionality
    const ONE_SECOND = 1000;
    document.getElementById("time_to_next_race").innerHTML = time_to_next_race;

    // When the race is on it says "Racing", so we can't -1 in this case
    if (Number.isInteger(time_to_next_race)) {
        setTimeout(function () {
            document.getElementById("time_to_next_race").innerHTML = time_to_next_race - 1;
        }, ONE_SECOND);
    }


    // Initiates the slow-mo effect
    if (horse_has_finished) {
        // Stops the track as the horses are about to hit the finish line
        race_track.style.animationPlayState = "paused";

        // Slows the running animations for the slow-mo effect
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
=======
    // Called when there's incoming data on the websocket for this channel
    const messages = document.getElementById('Horse Race');
    const message  = document.createElement('p');

    message.innerHTML = data["body"];
    messages.insertBefore(message, messages.firstChild);
>>>>>>> 914d31eb3c33807905e55dd705c76cd2b5e02cec
  }
});
