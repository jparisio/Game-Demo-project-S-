
// SET VALUES:
//-----------------------------------------------------------------------------
time			= (time + .5 * 0.05) mod 1;



if input_check("shoot") strength_y = lerp(strength_y, -1, .05);


// DRAW:
//-----------------------------------------------------------------------------
var _bullets = obj_player.gun.get_bullets(); // Get bullets from the player's gun
var _bullet_index = obj_player.gun.get_index();
var bullet_spacing = 32; // Space between bullets
var x_start = 50; // X starting position for drawing
var y_start = display_get_gui_height() - 50; // Y position at the bottom of the screen

for (var i = 0; i < array_length(_bullets); i++) {
    var bullet_state = _bullets[i];
    if (bullet_state == -1) {
		//draw empty shell (I want to play anim eventually of the bullet spinning out of the socket)
        draw_sprite(spr_bullet_ui, 1, x_start + (i * bullet_spacing), y_start); // Draw with image_index 1
    } else {
		//draw the current bullet to be rotating
		var rotation_range = 7; // Maximum rotation in either direction
		var frequency = 0.005; // Speed of oscillation

		// Calculate oscillating angle using sine wave
		var rot = sin(current_time * frequency) * rotation_range;
		if(i == _bullet_index){
			       
			gpu_set_tex_filter_ext(u_distort_tex, true);


			shader_set(shader);
				texture_set_stage(u_distort_tex, distort_tex);
				shader_set_uniform_f(u_time, time);
				shader_set_uniform_f(u_strength,	strength_x, strength_y);
				shader_set_uniform_f(u_size,		size);
				shader_set_uniform_f(u_bend,		bend);
	
				draw_sprite(sprite, 0, x_start + (i * bullet_spacing), y_start);
			shader_reset();

			gpu_set_tex_filter(false);
			draw_sprite_ext(bullet_state.sprite, 0, x_start + (i * bullet_spacing), y_start, 1, 1, rot, c_white, 1); 
		} else {
			draw_sprite(bullet_state.sprite, 0, x_start + (i * bullet_spacing), y_start);
		}

    }
}

