// Import the consumer instance from the channels to manage websockets
import consumer from "channels/consumer"

// Create a subscription to the "HorseRaceChannel" so all gamblers view the same horse positions on the track
consumer.subscriptions.create("HorseRaceChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  // Callback function when a message is received from the server
  received(data) {
    if (document.getElementById('race_track') == null) {
      return;
    }

    const HORSES = data.message.horses;
    const RESETTING = data.message.resetting; // If the horse race enters it's reset phase
    const TIME_TO_NEXT_RACE = data.message.time_to_next_race;

    // Constants for controlling race animation behavior and timing
    const ANIMATION_PAUSE_DELAY = 3000; // Matches the CSS transition time
    const POSITION_WHEN_BETS_CLOSE = 70; // Matches with the Servers bet close time
    const STARTING_RACE_POSITION = 0;
    const ENDING_RACE_POSITION = 100;

     // Flags to track race and betting status
    let race_has_started = false;
    let horse_has_finished = false;
    let is_betting_closed = false;

    // Get all the elements representing horses in the race
    const HORSE_DIVS = document.getElementsByClassName("race_horse");

    // Loop through each horse and update its position and animation state
    let index = 0;
    HORSES.forEach(horse => {
      const HORSE_IMG = HORSE_DIVS[index];

      // Check if betting is closed when the horse reaches a certain position on the field
      if (horse.position >= POSITION_WHEN_BETS_CLOSE) {
          is_betting_closed = true;
      }

      // Caps the horses position to 90% of field width
      HORSE_IMG.style.left = Math.min(100, horse.position) * 0.90 + "%"; 

      // Stop the horse when it finishes the race
      if (horse.position >= ENDING_RACE_POSITION) {
          setTimeout(function() {
            HORSE_IMG.style.animationPlayState = "paused";
          }, ANIMATION_PAUSE_DELAY);

          // The race has started and a horse has finished
          race_has_started = true;
          horse_has_finished = true;

      // Stop the horse if the race hasn't started
      } else if (horse.position == STARTING_RACE_POSITION) {
        HORSE_IMG.style.animationPlayState = "paused";

      // If the horses aren't at the start or end, they must be racing
      } else {
          race_has_started = true;
          HORSE_IMG.style.animationPlayState = "running";
      }

      index += 1;
    });

    // Get the race track element
    const RACE_TRACK = document.getElementById("race_track");

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
    if (RESETTING) {
        // Clear the tables
        document.getElementById("horse_wager_placed_body").innerHTML = "";
        document.getElementById("horse_wager_payout_body").innerHTML = "";

        // Move the track back so it looks less janky
        RACE_TRACK.style.animationPlayState = "running";
        setTimeout(function() {
          RACE_TRACK.style.animationPlayState = "paused";
        }, ANIMATION_PAUSE_DELAY);
    }

    /// Countdown clock functionality
    const ONE_SECOND = 1000;
    document.getElementById("time_to_next_race").innerHTML = TIME_TO_NEXT_RACE;

    // When the race is on it says "Racing", so we can't -1 in this case
    if (Number.isInteger(time_to_next_race)) {
        setTimeout(function () {
            document.getElementById("time_to_next_race").innerHTML = TIME_TO_NEXT_RACE - 1;
        }, ONE_SECOND);
    }


    // Initiates the slow-mo effect
    if (horse_has_finished) {
        // Stops the track as the horses are about to hit the finish line
        race_track.style.animationPlayState = "paused";

        // Slows the running animations for the slow-mo effect
        index = 0
        HORSES.forEach(horse => {
            const HORSE_IMG = HORSE_DIVS[index];
            HORSE_IMG.style.animationDuration = "1s";
            index += 1;
        });

    // Unsets the slow-mo effects
    } else if (!race_has_started) {
        index = 0
        HORSES.forEach(horse => {
            const HORSE_IMG = HORSE_DIVS[index];
            HORSE_IMG.style.animationDuration = "0.1s";
            index += 1;
        });
    } else {
        race_track.style.animationPlayState = "running";
    }
  }
});
