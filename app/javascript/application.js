// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

// Application event listener to change background music based on selected pages
document.addEventListener("turbo:load", function() {
    // Variable for tracking if music is playing
    let musicPlaying = false;

    // Get the background audio/music element
    let audio = document.getElementById("background-audio");

    // Return if we have no audio
    if (!audio) return;

    // Music files based on the page path
    const MUSIC_FILES = {
        "/roulette/roulette_board": "/audios/delfino_casino.mp3", // Roulette Music
        "/": "/audios/whims_of_fate_casino.mp3", // Lobby music
        "/horse_race/index": "/audios/luigis_casino.mp3" // Horse Racing music
    };

    // Get the current page's path
    let currentPage = window.location.pathname;
    
    // If the page starts with /users/, set the music to a specific file
    if (currentPage.startsWith("/users/") && currentPage !="/users/new") {
        MUSIC_FILES[currentPage] = "/audios/golden_palace.mp3"; // Golden Palace music
    }

    // If the user clicks the screen and music isn't playing, start it up
    document.addEventListener("click", function() {
        // If the audio element exists, and music isn't playing, then continue
        if (audio && !musicPlaying) {
            // Get the audio source
            audio.src = MUSIC_FILES[currentPage];

            // Reload the audio and play it
            audio.load()
            audio.volume = 0.2
            audio.play();
            musicPlaying = true;
        }
    });

    // Check if the current page has a specific music file
    if (MUSIC_FILES[currentPage]) {
        // If it does, change the audio source
        audio.src = MUSIC_FILES[currentPage];

        // Reload the audio and play it
        musicPlaying = true;
        audio.load();
        audio.volume = 0.2
        audio.play().catch(error => {console.log("Autoplay blocked:", error); musicPlaying = false});
    } else {
        // If no specific music file is found, keep the default music
        musicPlaying = true;
        audio.src = "/audios/all_time_classics.mp3";
        audio.volume = 0.2
        audio.play().catch(error => {console.log("Autoplay blocked:", error); musicPlaying = false});
    }
});