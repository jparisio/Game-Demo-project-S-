stop = true;
create_hitbox("boss", self, x, y, 1, spr_crosshair_hurtbox, 3, 15);
audio_play_sound(snd_gunshot, 1, 0);
create_shake();
