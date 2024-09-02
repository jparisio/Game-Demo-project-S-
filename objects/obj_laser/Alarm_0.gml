sprite_index = spr_laser;
create_hitbox("boss", self, x, y, 1, spr_laser_hitbox, 60 , 10, image_yscale);
alarm[1] = alarm_active;
audio_play_sound(snd_lazers_active, 5, 0)
image_xscale = 0.4;
image_speed = 1;