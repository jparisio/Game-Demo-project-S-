// Step Event

// Step 1: Detect Collision and Calculate Direction
if (place_meeting(x, y, obj_player)) {
    var dx = obj_player.x - x;
    var dy = obj_player.y - y;
    
    // Check if the player is far enough to avoid jittering
    if (point_distance(x, y, obj_player.x, obj_player.y) > distance_threshold) {
        var new_angle = point_direction(0, 0, dx, dy);

        // Normalize the angle to be between -180 and 180 degrees
        new_angle = angle_difference(image_angle, new_angle);

        // Check if the angle difference is above the threshold
        if (abs(new_angle) > angle_threshold) {
            // Clamp the new target angle between -60 and 60 degrees
            target_angle = clamp(new_angle, -60, 60);
        }
    }
} else {
    // Slowly return to the default angle (e.g., 0 degrees)
    target_angle = lerp(target_angle, 0, 0.05);
}

// Step 2: Smoothly interpolate the image angle towards the target angle
image_angle = lerp(image_angle, target_angle, 0.1);

// Step 3: Clamp the final image angle between -60 and 60 degrees
image_angle = clamp(image_angle, -60, 60);
