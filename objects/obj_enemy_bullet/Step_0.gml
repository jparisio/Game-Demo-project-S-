image_angle = direction;
speed = Approach(speed, max_speed, .5);
if speed != 0 move_dir = sign(speed);

var p_dir = direction;
// Set the particle orientation to the bullet's direction
part_type_orientation(global.bullet_trail, p_dir, p_dir, 0, 0, 0);
part_type_color3(global.bullet_trail, c_white, c_red, c_red);

// Emit particles at the bullet's current position (x, y) based on the particle type
part_particles_create(global.part_sys, x, y, global.bullet_trail, 1);