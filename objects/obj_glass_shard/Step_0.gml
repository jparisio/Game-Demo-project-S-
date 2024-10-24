if (speed == 0 and alarm[0] == -1) alarm[0] = 120;
if fade image_alpha -= .2;
if image_alpha <= 0 instance_destroy();


// Vertical collision (floor and ceiling)
if place_meeting(x, y + vspeed, obj_wall_parent) {
    if (vspeed > 1) {
        vspeed *= -0.5;  // Bounce with energy loss
    } else {
        vspeed = 0;
        while (!place_meeting(x, y + 1, obj_wall_parent)) {
            y++;  // Settle on the floor
        }
        gravity = 0;
    }
} else {
    gravity = 0.5;  // Apply gravity when in the air
}

// Horizontal collision (walls)
if place_meeting(x + hspeed, y, obj_wall_parent) {
    hspeed *= -0.5;  // Bounce off the walls with energy loss
} else {
    friction = 0.1;  // Slow down naturally when moving
}

// Apply movement
x += hspeed;
y += vspeed;

image_angle += 1 * hspeed;

// Destroy the object if it's outside the room bounds
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}