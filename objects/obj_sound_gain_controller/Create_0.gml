// List of sounds to quiet and then fade back
playing_sounds = [
    snd_explosion2, 
    snd_lazer_windup, 
    snd_lazers_active, 
    snd_gunshot, 
    snd_reload, 
    snd_rocket,
    snd_temp_song,
    snd_rocket_startup
];

// Array to hold the structs with sound information
sound_info_array = [];

// Step 1: Store current gain and quiet the sounds
for (var i = 0; i < array_length(playing_sounds); i++) {
    if (audio_is_playing(playing_sounds[i])) {
        // Retrieve current gain
        var current_gain = audio_sound_get_gain(playing_sounds[i]);

        // Store the sound ID and its original gain in a struct
        var sound_info = {
            sound_id: playing_sounds[i],
            original_gain: current_gain
        };

        // Add the struct to the array
        array_push(sound_info_array, sound_info);

        // Lower the volume to 20%
        audio_sound_gain(playing_sounds[i], 0.2, 0);
    }
}

// Step 2: Play the player hit sound
audio_play_sound(snd_player_hit, 30, 0, 35);

// Step 3: Set an alarm to restore the original gains
alarm[0] = 15; // Set to 1 second delay (30 frames at 30 FPS)

