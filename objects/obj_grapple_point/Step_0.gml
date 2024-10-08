fsm.step();

//coll_line = collision_line(x, y, obj_player.x, obj_player.y - 20, obj_24_wall, false, false)

// Manage cooldown
if (cooldown && alarm[0] == -1) {
    alarm[0] = 120; // Set the cooldown duration
}


//make it follow something 
if (follow != noone) {
	x = follow.x;
	y = follow.y - offset;
}
