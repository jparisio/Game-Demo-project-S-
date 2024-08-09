

if(!instance_exists(obj_exit_animation)) {
	with(instance_create_layer(x, y, "Instances", obj_exit_animation)){
		next_room = other.next_room;
		target_x = other.target_x;
		target_y = other.target_y;
	}
	
}