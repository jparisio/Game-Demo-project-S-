event_inherited();

//screen shake
create_shake("small");

//sound effect
audio_play_sound(snd_gunshot, 5, 0, 0.3);
audio_play_sound(snd_bullet_shell, 4, 0, 0.7);

// Create Event

// Create the particle system
part_sys = part_system_create();

// Create the particle type for the trail
bullet_trail = part_type_create();

// Set the shape of the particle to a sphere (you can change this if desired)
part_type_shape(bullet_trail, pt_shape_sphere);

// Set the size of the particle (adjust size to your preference)
part_type_size(bullet_trail, 0.20, 0.20, 0, 0);

// Scale the particle to make it more horizontal (to resemble a trail)
part_type_scale(bullet_trail, 2.4, .4);

// Set the particle orientation (static for now, we will adjust in the Step event)
part_type_orientation(bullet_trail, 0, 0, 0, 0, 0);

// Set the color of the particles (light yellow, or you can customize)
part_type_color3(bullet_trail, c_white, c_yellow, c_yellow);

// Set the alpha to fade out the particles over time
part_type_alpha3(bullet_trail, 1, 1, 0);

// Set blending mode (optional, but looks better for certain particle effects)
part_type_blend(bullet_trail, 1);

// Set particle lifetime (how long the particle will live)
part_type_life(bullet_trail, 4, 4);

// Set the particle speed to 0 (particles will not move on their own)
part_type_speed(bullet_trail, 0, 0, 0, 0);

// Set gravity to 0 (so the particles stay in place)
part_type_gravity(bullet_trail, 0, 0);
