sprite = spr_flame;
distort_sprite	= spr_flame_distortion_map;
distort_tex		= sprite_get_texture(distort_sprite, 0);

shader			= sh_flame_distortion;
u_distort_tex	= shader_get_sampler_index(shader, "distort_tex");
u_time			= shader_get_uniform(shader, "time");
u_strength		= shader_get_uniform(shader, "strength");
u_size			= shader_get_uniform(shader, "size");
u_bend			= shader_get_uniform(shader, "bend");

time			= random(1);




