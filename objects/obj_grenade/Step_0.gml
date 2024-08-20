image_angle += 10;

// Update horizontal position based on x_velocity
x += lengthdir_x(x_velocity, angle_to_player);

// Apply custom gravity to y_velocity and update vertical position
y_velocity += y_gravity;
y += y_velocity;

// Check for collision with obj_player or obj_wall
if (place_meeting(x, y, obj_hurtbox) || place_meeting(x, y, obj_wall)) {
    // Trigger explosion (e.g., create explosion object, deal damage, etc.)
    instance_destroy(); // Destroy the grenade object
}

