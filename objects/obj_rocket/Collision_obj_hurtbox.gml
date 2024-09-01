if !dead {
	//reduce hp
	obj_player.hp -= self.damage;
	//set invulnerbaility
	obj_player.be_invulnerable = true;
	//shake screen a lot
	if(!instance_exists(obj_screenshake_large)){
		create_shake();
	}
	//hit pause
	hit_pause(30);
	//destroy so it doesnt infinately collide with the player
	if(instance_exists(obj_hurtbox)){
		instance_destroy(obj_hurtbox);
	}
	
	//sound controller for being hit
	instance_create_layer(x, y, "Instances", obj_sound_gain_controller);
}