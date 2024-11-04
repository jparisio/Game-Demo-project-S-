
// SET VALUES:
//-----------------------------------------------------------------------------
time			= (time + .5 * 0.05) mod 1;

var strength_x	= .231;		// [0, 0.3]
var strength_y	= .77;		// [0, 1]
var size		= .7;		// [0.25, 0.75]
var bend		= 0;		// [-1, +1]


// DRAW:
//-----------------------------------------------------------------------------

//draw_self();

gpu_set_tex_filter_ext(u_distort_tex, true);


shader_set(shader);
	texture_set_stage(u_distort_tex, distort_tex);
	shader_set_uniform_f(u_time, time);
	shader_set_uniform_f(u_strength,	strength_x, strength_y);
	shader_set_uniform_f(u_size,		size);
	shader_set_uniform_f(u_bend,		bend);
	
	draw_sprite(sprite, 0, x, y);
shader_reset();

gpu_set_tex_filter(false);

