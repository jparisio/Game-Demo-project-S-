fsm.step();

coll_line = collision_line(x, y, obj_player.x, obj_player.y - 20, obj_wall_parent, false, false)
show_debug_message(fsm.get_current_state());

// Manage cooldown
if (cooldown && alarm[0] == -1) {
    alarm[0] = 120; // Set the cooldown duration
}


//make it follow something 
if (follow != noone) {
	x = follow.x;
	y = follow.y - offset;
}
