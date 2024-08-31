if(creator == "player"){
	//subtract hp and send backwards
	other.hp -= obj_player.damage
	//create screen shake
	instance_create_layer(x,y,"Instances", obj_screenshake);
	//hitflash
	other.flash_alpha = 0.8;
	//create hit effect
	var _slash = instance_create_layer(other.x, other.y, "Instances", obj_hit_effect);
	_slash.image_xscale = image_xscale;
	_slash.image_angle = random_range(20, -20);
	
	//play audio
	var _pitch = choose (1, 1.1, 1.2)
	audio_play_sound(snd_hit_enemy2, 1, 0, 3, 0, _pitch);
}