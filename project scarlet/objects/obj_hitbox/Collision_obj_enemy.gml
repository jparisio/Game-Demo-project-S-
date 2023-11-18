if(creator == "player"){
	if other.hp > 2{
		//subtract hp and send backwards
		other.hp -= obj_player.damage
		other.hsp = obj_player.pushback * sign(obj_player.facing)
		//create screen shake
		instance_create_layer(x,y,"Instances", obj_screenshake);
		//hitflash
		other.flash_alpha = 0.8;
		//create hit effect
		var _slash = instance_create_layer(other.x, other.y, "Instances", obj_hit_effect);
		_slash.image_xscale = image_xscale;
		_slash.image_angle = random_range(20, -20);
	} else{ //kill enemy and create the blood splat
		//subtract big damage (makes no sense because theyre dead if this state happens lol)
		other.hp -= damage * 2;
		other.hsp = obj_player.pushback * sign(obj_player.facing)
		//shake large
		create_shake();
		//cause hit flash
		other.flash_alpha = 0.8;
		//create the slashed effect
		var _slash = instance_create_layer(other.x, other.y, "Instances", obj_hit_effect);
		_slash.image_xscale = image_xscale;
		_slash.image_angle = random_range(20, -20);
		//create blood and blood angle
		var _angled = random(2)
		if(_angled <= 1) repeat(30) create_blood(facing, other.x -10, other.y-40, true) else repeat(30) create_blood(facing, other.x -10, other.y-40, false)
		//hit pause
		hit_pause(20)
	}
}

