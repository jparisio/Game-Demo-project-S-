// Check if obj_player is overlapping any of the wave points
for (var i = 0; i < num_points; i++) {
    var point_x_pos = start_x_position + ((i - 3) * point_spacing);

    // Check if the player is overlapping this specific point
    if (instance_position(point_x_pos, y, obj_player) != noone) {

        var effect_range = 2; // Number of points affected on either side
        
        // Apply force to the closest point and its neighbors if not already applied
        for (var j = -effect_range; j <= effect_range; j++) {
            var index = i + j;
            if (index >= 0 && index < num_points) {
                if (!points[index].force_applied) {
                    // Apply a diminishing force based on distance from the player's position
                    var distance_factor = (effect_range - abs(j)) / effect_range;
                    points[index].velocity = magnitude * distance_factor;
                    points[index].force_applied = true; // Set flag to true for this point
                }
            }
        }
    } else {
        // Reset the force_applied flag when obj_player is no longer colliding with this point
        points[i].force_applied = false;
    }
}

// Update the wave points using the same spring mechanics as before
for (var i = 0; i < num_points; i++) {
    var point = points[i];
    
    // Add a small constant wave to the water so it isn't sitting still
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
