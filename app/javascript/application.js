// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

// Application event listener to change background music based on selected pages
document.addEventListener("turbo:load", function() {
    // Variable for tracking if music is playing
    var music_playing = false;

    // Get the background audio/music element
    var audio = document.getElementById("background-audio");

    // Return if we have no audio
    if (!audio) return;

    // Music files based on the page path
    var musicFiles = {
        "/roulette/roulette_board": "/audios/delfino_casino.mp3", // Roulette Music
        "/": "/audios/whims_of_fate_casino.mp3", // Lobby music
        "/horse_race/index": "/audios/luigis_casino.mp3" // Horse Racing music
    };

    // Get the current page's path
    var currentPage = window.location.pathname;
    
    // If the page starts with /users/, set the music to a specific file
    if (currentPage.startsWith("/users/") && currentPage !="/users/new") {
        musicFiles[currentPage] = "/audios/golden_palace.mp3"; // Golden Palace music
    }

    // If the user clicks the screen and music isn't playing, start it up
    document.addEventListener("click", function() {
        // If the audio element exists, and music isn't playing, then continue
        if (audio && !music_playing) {
            // Get the audio source
            audio.src = musicFiles[currentPage];

            // Reload the audio and play it
            audio.load()
            audio.volume = 0.2
            audio.play();
            music_playing = true;
        }
    });

    // Check if the current page has a specific music file
    if (musicFiles[currentPage]) {
        // If it does, change the audio source
        audio.src = musicFiles[currentPage];

        // Reload the audio and play it
        music_playing = true;
        audio.load();
        audio.volume = 0.2
        audio.play().catch(error => {console.log("Autoplay blocked:", error); music_playing = false});
    } else {
        // If no specific music file is found, keep the default music
        music_playing = true;
        audio.src = "/audios/all_time_classics.mp3";
        audio.volume = 0.2
        audio.play().catch(error => {console.log("Autoplay blocked:", error); music_playing = false});
    }
});