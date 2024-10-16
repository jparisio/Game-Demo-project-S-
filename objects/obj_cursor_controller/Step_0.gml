//lerp back to normal if enlarged
xscale = lerp(xscale, 1, .2);
yscale = lerp(yscale, 1, .2);


if(found_hover){
	if counter <= 30 counter += 1/30
	xscale = AnimcurveTween(xscale, 3, acElasticOut, counter)
	yscale = AnimcurveTween(yscale, 3, acElasticOut, counter)
	image_angle += 5;
} else {
	image_angle = lerp(image_angle, 90, .4);
	counter = 0;
}


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
