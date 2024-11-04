time			= (time + .5 * 0.05) mod 1;

//shader
gpu_set_tex_filter_ext(u_distort_tex, true);


	shader_set(shader);
		texture_set_stage(u_distort_tex, distort_tex);
		shader_set_uniform_f(u_time, time);
		shader_set_uniform_f(u_strength,	strength_x, strength_y);
		shader_set_uniform_f(u_size,		size);
		shader_set_uniform_f(u_bend,		bend);
	
		//draw_sprite(sprite, 0, draw_x, draw_y);
		draw_sprite_ext(sprite, 0, draw_x, draw_y, xscale, yscale, 1, c_white, 1); 
	shader_reset();

gpu_set_tex_filter(false);
	
if(fsm.get_current_state() == "active"){
	
	//draw the current bullet to be rotating
	var rotation_range = 7; // Maximum rotation in either direction
	var frequency = 0.005; // Speed of oscillation
	// Calculate oscillating angle using sine wave
	var rot = sin(current_time * frequency) * rotation_range;		       
	draw_sprite_ext(bullet_sprite, 0, draw_x, draw_y, 1, 1, rot, c_white, 1); 
	
} else if(fsm.get_current_state() == "loaded"){
	//draw without rotation 
	draw_sprite(bullet_sprite, 0, draw_x, draw_y);
	
} else {
	//draw empty shell
	draw_sprite(bullet_sprite, 1, draw_x, draw_y);
	
}






