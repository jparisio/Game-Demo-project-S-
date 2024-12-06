


// Create the particle system
global.part_sys = part_system_create();

//bullet trails
global.bullet_trail = part_type_create();
part_type_shape(global.bullet_trail, pt_shape_sphere);
part_type_size(global.bullet_trail, 0.22, 0.22, 0, 0);
part_type_scale(global.bullet_trail, 2.3, .4);
part_type_orientation(global.bullet_trail, 0, 0, 0, 0, 0);
part_type_color3(global.bullet_trail, c_white, c_yellow, c_orange);
part_type_alpha3(global.bullet_trail, 1, 1, 0);
part_type_blend(global.bullet_trail, 1);
part_type_life(global.bullet_trail, 4, 4);
part_type_speed(global.bullet_trail, 0, 0, 0, 0);
part_type_gravity(global.bullet_trail, 0, 0);


global.player_trail = part_type_create();
part_type_sprite(global.player_trail, spr_ghost_jump, true, false, true);
part_type_size(global.player_trail, 1, 1, 0, 0);
part_type_scale(global.player_trail, 1, 1);
part_type_orientation(global.player_trail, 0, 0, 0, 0, 0);
part_type_color3(global.player_trail, #ffcdb2, #ffb4a2 ,#e5989b);
part_type_alpha3(global.player_trail, .1, .05, 0);
part_type_blend(global.player_trail, 1);
part_type_life(global.player_trail, 12, 12);
part_type_speed(global.player_trail, 0, 0, 0, 0);
part_type_gravity(global.player_trail, 0, 0);


global.hit_burst = part_type_create();
part_type_shape(global.hit_burst, pt_shape_disk);
part_type_size(global.hit_burst, 0.2, 0.5, 0, 0);
part_type_scale(global.hit_burst, .2, .2);
part_type_direction(global.hit_burst, 0, 360, 0, 0)
part_type_color3(global.hit_burst, c_white, c_white, c_white);
part_type_alpha3(global.hit_burst, 1, 1, 0);
part_type_blend(global.hit_burst, 0);
part_type_life(global.hit_burst, 30, 60);
part_type_speed(global.hit_burst, 1, 3, 0.1, 0);
part_type_gravity(global.hit_burst, 0.1, 270);

