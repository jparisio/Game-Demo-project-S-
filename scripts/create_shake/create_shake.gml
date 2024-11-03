function create_shake(shake_type = "large"){
	
	if(shake_type == "large"){
		global.screen_shake_magnitude = 30;
		instance_create_layer(0, 0, "Instances", obj_screenshake)
	} else if(shake_type = "small"){
		global.screen_shake_magnitude = 5;
		instance_create_layer(0, 0, "Instances", obj_screenshake)
	} else if(shake_type == "spring"){
		instance_create_layer(0, 0, "Instances", obj_screenshake_spring);
	}
}