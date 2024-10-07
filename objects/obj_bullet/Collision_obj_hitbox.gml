if(other.creator == "player"){
	
	speed *= -2;
	creator = obj_player;
	audio_play_sound(snd_bullet_deflect, 10, 0, 4, 0, 1.9);
	instance_create_layer(x, y, "Instances", obj_shrapnel_destroy);
	hit_pause(130);
}




