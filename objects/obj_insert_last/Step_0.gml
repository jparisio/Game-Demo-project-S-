if place_meeting(x, y, obj_player) {
	obj_player.gun.set_bullet(_bullet);
	audio_play_sound(snd_reload_item, 15, 0);
	instance_destroy();
}


