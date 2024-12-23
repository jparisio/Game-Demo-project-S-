image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);

var p_dir = direction;
part_type_orientation(global.bullet_trail, p_dir, p_dir, 0, 0, 0);

// Emit particles at the bullet's current position (x, y) based on the particle type
part_particles_create(global.part_sys, x, y, global.bullet_trail, 1);
