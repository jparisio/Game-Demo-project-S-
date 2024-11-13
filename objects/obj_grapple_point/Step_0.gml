fsm.step();

coll_line = collision_line(x, y, obj_player.x, obj_player.y - 20, obj_wall_parent, false, false)

// Manage cooldown
if (cooldown && alarm[0] == -1) {
    alarm[0] = 120; // Set the cooldown duration
}


//make it follow something 
if (follow != noone) {
	x = follow.x;
	y = follow.y - offset;
}


//edge case for chainsaws 

if (active && follow != noone && follow.object_index == obj_chainsaw) {
    follow.active = true;
}



//indicator 
indicator.draw_x = x;
indicator.draw_y = y - 20;