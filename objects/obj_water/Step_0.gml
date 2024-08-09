// Check if obj_player is overlapping the wave object
if (instance_place(x, y, obj_player) != noone) {
    var player_x_pos = obj_player.x;
    var relative_x_pos = player_x_pos - start_x_position;
    var closest_point_index = round(relative_x_pos / point_spacing);
    var effect_range = 5; // Number of points affected on either side
    
    if (closest_point_index >= 0 && closest_point_index < num_points) {
        // Apply force to the closest point and its neighbors if not already applied
        for (var i = -effect_range; i <= effect_range; i++) {
            var index = closest_point_index + i;
            if (index >= 0 && index < num_points) {
                if (!points[index].force_applied) {
                    // Apply a diminishing force based on distance from the click
                    var distance_factor = (effect_range - abs(i)) / effect_range;
                    points[index].velocity = magnitude * distance_factor;
                    points[index].force_applied = true; // Set flag to true
                }
            }
        }
    }
} else {
    // Reset the force_applied flag when obj_player is no longer colliding
    for (var i = 0; i < num_points; i++) {
        points[i].force_applied = false;
    }
}

// Update the wave points using the same spring mechanics as before
for (var i = 0; i < num_points; i++) {
    var point = points[i];
	
	//add a small constant wave to the water so it isnt sitting still
	point.velocity += sin((i * point_spacing) * 0.1 + current_time * 0.5) * 0.2;
	point.velocity += sin((i * point_spacing) * 0.15 - current_time * 0.5) * 0.15;
    
    // Calculate the force based on Hooke's law
    var force = -spring_constant * (point.y_current - point.y_rest);
    
    // Update the velocity and apply damping
    point.velocity += force;
    point.velocity *= damping;
    
    // Update the current y-position
    point.y_current += point.velocity;
}

// Propagate the wave to neighboring points
for (var i = 1; i < num_points - 1; i++) {
    points[i-1].y_current += spread * (points[i].y_current - points[i-1].y_current);
    points[i+1].y_current += spread * (points[i].y_current - points[i+1].y_current);
}
