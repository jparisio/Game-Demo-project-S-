if(creator == "enemy" or creator == "boss"){
	//reduce hp
	obj_player.hp -= self.damage;
	//set invulnerbaility
	obj_player.be_invulnerable = true;
	//shake screen a lot
	create_shake();
	//hit pause
	hit_pause(30);
	//destroy so it doesnt infinately collide with the player
	if(instance_exists(obj_hurtbox)){
		instance_destroy(obj_hurtbox);
	}
	//sound controller for being hit
	//audio_play_sound(snd_player_hit, 20, 0, .5);
	//instance_create_layer(x, y, "Instances", obj_sound_gain_controller);
	instance_create_layer(x, y, "Instances", obj_player_damaged);
}
