


// Create the particle system
global.part_sys = part_system_create();

//bullet trails
global.bullet_trail = part_type_create();
part_type_shape(global.bullet_trail, pt_shape_sphere);
part_type_size(global.bullet_trail, 0.20, 0.20, 0, 0);
part_type_scale(global.bullet_trail, 2.4, .4);
part_type_orientation(global.bullet_trail, 0, 0, 0, 0, 0);
part_type_color3(global.bullet_trail, #fdffc9, #f9ff59, c_yellow);
part_type_alpha3(global.bullet_trail, 1, 1, 0);
part_type_blend(global.bullet_trail, 1);
part_type_life(global.bullet_trail, 4, 4);
part_type_speed(global.bullet_trail, 0, 0, 0, 0);
part_type_gravity(global.bullet_trail, 0, 0);