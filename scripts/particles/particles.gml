


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



global.death_part = part_type_create();
part_type_shape(global.death_part, pt_shape_disk);
part_type_size(global.death_part, .08, .08, -.001, 0);
part_type_scale(global.death_part, .24, .24);
part_type_color3(global.death_part, c_white, c_white, c_white);
part_type_speed(global.death_part, .2, .4, -0.01, 0);
part_type_life(global.death_part, 180, 180);
part_type_direction(global.death_part, 0, 360, 0, 0);
part_type_alpha3(global.death_part, 1, 1, 0);

global.hit_burst = part_type_create();
part_type_shape(global.hit_burst, pt_shape_disk);
part_type_size(global.hit_burst, 1.2, 1.2, -.06, 0);
part_type_scale(global.hit_burst, .24, .24);
part_type_size_y(global.hit_burst, .1, .1, 0, 0);
part_type_color3(global.hit_burst, c_white, c_white, c_white);
part_type_alpha3(global.hit_burst, 1, 1, 1);
part_type_blend(global.hit_burst, true);
part_type_life(global.hit_burst, 19, 19);
part_type_speed(global.hit_burst, 1, 4, -0.1, 0);
part_type_death(global.hit_burst, 1, global.death_part);

global.hit_circle = part_type_create();
part_type_shape(global.hit_circle, pt_shape_disk);
part_type_size(global.hit_circle, 1, 1.2, -.06, 0);
part_type_scale(global.hit_circle, .2, .2);
part_type_color3(global.hit_circle, c_white, c_white, c_white);
part_type_alpha3(global.hit_circle, 1, 1, 1);
part_type_blend(global.hit_circle, true);
part_type_life(global.hit_circle, 40, 40);
part_type_direction(global.hit_circle, 0, 360, 0, 0);
part_type_speed(global.hit_circle, .3, 1, -0.1, 0);


global.shotgun_blast = part_type_create();
part_type_shape(global.shotgun_blast, pt_shape_disk);
part_type_size(global.shotgun_blast, 2.4, 2.4, -.12, 0);
part_type_scale(global.shotgun_blast, .24, .24);
part_type_size_y(global.shotgun_blast, .05, .05, 0, 0);
part_type_color3(global.shotgun_blast, c_yellow, c_orange, c_white);
part_type_alpha3(global.shotgun_blast, 1, 1, 1);
part_type_blend(global.shotgun_blast, false);
//part_type_life(global.shotgun_blast, 19, 19);
part_type_speed(global.shotgun_blast, 2, 6, -0.1, 0);
