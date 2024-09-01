if !dead {
	//reduce hp
	obj_player.hp -= self.damage;
	//set invulnerbaility
	obj_player.be_invulnerable = true;
	//shake screen a lot
	create_shake();
	//hit pause
	hit_pause(120)
	//destroy so it doesnt infinately collide with the player
	if(instance_exists(obj_hurtbox)){
		instance_destroy(obj_hurtbox);
	}
	mask_index = spr_empty;
	sprite_index = spr_empty;
	alarm[2] = 30;
	instance_create_layer(x, y, "Instances", obj_explosion);
}