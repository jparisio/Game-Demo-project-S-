creator = noone;
move_dir = 0;
max_speed = 30;
//override hit enemy function for different bullet effects
hit_enemy = function(){
	if (other.fsm.get_current_state() != "stunned" and other.hp > 0){
		other.fsm.change("stunned");
		instance_destroy(self);
	}
}


