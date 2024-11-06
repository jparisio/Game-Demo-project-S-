add_bullet = function(_bullet){
	if place_meeting(x, y, obj_player) {
		var _added = obj_player.gun.add_bullet(_bullet);
		if _added {
			audio_play_sound(snd_reload_item, 15, 0);
			instance_destroy();
		}
	}
}