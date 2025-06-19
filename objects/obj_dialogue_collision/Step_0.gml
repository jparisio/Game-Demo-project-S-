//add a little buffer after player exits dialogue so it doesnt auto instantiate it again
if(!instance_exists(obj_text)){
	timer--;
} else timer = 5;
//clamp it
timer = clamp(timer, -1, 5);

//create the hover button
if place_meeting(x, y, obj_player){
	if(!instance_exists(obj_enter_button)){
		if(obj_player.talking == false) self.button_id = instance_create_layer(create_above.x, create_above.y - 60, "Instances", obj_enter_button);
	}
} else if (instance_exists(obj_enter_button) and instance_exists(button_id)) self.button_id.active = false;

