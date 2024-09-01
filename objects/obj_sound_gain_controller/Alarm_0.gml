// Alarm[0] event - Restore original gains
for (var i = 0; i < array_length(sound_info_array); i++) {
    var sound_info = sound_info_array[i];

    // Restore the original gain if the sound is still playing
    if (audio_is_playing(sound_info.sound_id)) {
        audio_sound_gain(sound_info.sound_id, sound_info.original_gain, 135); // Fade dback over 1 second
    }
}


instance_destroy();
