creator = noone;
move_dir = 0;
max_speed = 30;
//override hit enemy function for different bullet effects
hit_enemy = function(){
	if (other.fsm.get_current_state() != "stunned" and other.hp > 0 and other.object_index != obj_enemy_grapple_point){
		other.fsm.change("stunned");
		//hit pause and freeze frame
		hit_pause(40);
		create_shake("medium");
		//destroy self
		instance_destroy(self);
	}
}

hit_player = function(){
	if (obj_player.fsm.get_current_state() != "injured" and obj_player.hp > 0){
		obj_player.fsm.change("injured");
		instance_destroy(self);
	}
}


