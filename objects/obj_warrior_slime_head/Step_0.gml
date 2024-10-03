// Vertical collision (floor and ceiling)
if place_meeting(x, y + vspeed, obj_wall) {
    if (vspeed > 1) {
        vspeed *= -0.5;  // Bounce with energy loss
    } else {
        vspeed = 0;
        while (!place_meeting(x, y + 1, obj_wall)) {
            y++;  // Settle on the floor
        }
        gravity = 0;
    }
} else {
    gravity = 0.5;  // Apply gravity when in the air
}

// Horizontal collision (walls)
if place_meeting(x + hspeed, y, obj_wall) {
    hspeed *= -0.5;  // Bounce off the walls with energy loss
} else {
    friction = 0.1;  // Slow down naturally when moving
}

// Apply movement
x += hspeed;
y += vspeed;
