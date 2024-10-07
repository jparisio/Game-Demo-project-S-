//// Wall speed (positive for moving down, negative for moving up)
//speedd = -2; 

//// Move the wall vertically
//y += speedd;



with (obj_player) {
    if (place_meeting(x, bbox_bottom, other)) {
        // Check if moving vertically will push the player into a wall
        if (!place_meeting(x, y + other._speed, obj_wall_parent)) {
            // Move the player along with the platform
            y += other._speed;
        } else {
            // Prevent the player from being pushed into a wall
			//store _speed
			other.prev_speed = other._speed;
            other._speed = 0;
			other.y -= 4;
        }
    }
}


if(_speed == 0) if !place_meeting(x, y, obj_player) _speed = prev_speed
