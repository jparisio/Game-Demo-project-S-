//lerp back to normal if enlarged
xscale = lerp(xscale, 1, .2);
yscale = lerp(yscale, 1, .2);


if(found_hover){
	if counter <= 30 counter += 1/30
	xscale = AnimcurveTween(1, 3, acElasticOut, counter)
	yscale = AnimcurveTween(1, 3, acElasticOut, counter)
	image_angle += 5;
} else {
	//calculate a spin ddepeding on how fast the mouse 
	//is moved horizontally, and constanbtly smooth out to no spin wwhen mouse isnt moving 
	counter = 0;
	
	var mouse_vel_x = mouse_x - previous_mouse_x;

    var threshold = 2; // Adjust this value as needed

	if (abs(mouse_vel_x) > threshold) {
	    // Only apply the spin if the movement exceeds the threshold
	    var spin_speed = 20;
	    image_angle += mouse_vel_x * spin_speed;
	}

    // Smoothly reduce spin to stop when mouse stops moving
	image_angle = lerp(image_angle, 0, 0.05);
}

previous_mouse_x = mouse_x;


found_hover = false;
with (obj_grapple_point) { // Loop through all points
	var in_list = ds_list_find_index(obj_player.grapple_target_list, self)
    if (point_in_circle(mouse_x, mouse_y, x, y, hover_radius) && !other.found_hover && in_list != -1){
        mouse_hovering = true;
        obj_cursor_controller.lock_on = self;
        other.found_hover = true; // Stop further checks
    } else {
        mouse_hovering = false;
    }
}

// If no points are hovered, reset the lock
if (!found_hover) {
    obj_cursor_controller.lock_on = noone;
}
