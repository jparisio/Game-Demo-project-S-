event_inherited();

//screen shake
create_shake("small");

//sound effect
audio_play_sound(snd_gunshot, 10, 0);
audio_play_sound(snd_bullet_shell, 7, 0);

alarm[0] = -1;

bounced = true;
destructable = false;