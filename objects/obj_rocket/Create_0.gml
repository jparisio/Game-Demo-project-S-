image_angle = point_direction(x,y, obj_player.x, obj_player.y);

image_xscale = -1;

alarm[0] = 150;

alarm[1] = 120;

//this is a buffer alarm after they become inactive to make sure the particles finish their animations
//kinda hacky and I wanna change later
alarm[2] = -1;

val = 0;
fade_alpha = 0;
timer = 0;

target_angle = 0;
move_speed = 0;
radius = 200;
damage = 10;

//create_hitbox("boss", self, x, y, image_xscale, spr_rocket_hitbox, 150, 10)


//particle system
particle_system = part_system_create_layer("Player", 0);
particle_trail = part_type_create();
part_type_sprite(particle_trail, spr_rocket_trail, 1, 1, 0);
part_type_life(particle_trail, 20, 20);
part_type_alpha3(particle_trail, 1, 1, 0);
part_type_size(particle_trail, 1, 1.2, 0, 0);
