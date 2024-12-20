draw_sprite_ext(sprite_index, image_index, x, y, xscale * facing, yscale, image_angle, image_blend, image_alpha);

if (!instance_exists(obj_hurtbox) and be_invulnerable) {
		frame_counter++;
	    // make flash alpha move between 0 and 1 
		flash_alpha = sin(frame_counter/5) * 0.7
        // Activate the shader
        shader_set(sh_hit);
        
        // Draw the player with the red shader effect
        draw_sprite_ext(sprite_index, image_index, x, y, xscale * facing, yscale, image_angle, image_blend, flash_alpha);
	

        // Deactivate the shader after drawing
        shader_reset();
   }

//draw_set_color(c_white)

//if grapple_target != noone {
//	draw_line(x, y - sprite_height / 2, grapple_target.x, grapple_target.y);
//}

//draw_text(x, y - 40, string(jump));

//draw_circle(bbox_right + 32, bbox_bottom - 10, 1, false);

//draw_set_color(c_white)

//draw_text(x, y, string(approach_walksp));