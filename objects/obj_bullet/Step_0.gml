image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);

// Calculate the direction of the bullet's movement
var p_dir = direction;  // Use the bullet's current direction

// Set the particle orientation to the bullet's direction
part_type_orientation(bullet_trail, p_dir, p_dir, 0, 0, 0);

// Emit particles at the bullet's current position (x, y) based on the particle type
part_particles_create(part_sys, x, y, bullet_trail, 1);
