draw_sprite_ext(sprite_index, image_index, x, y, facing, image_yscale, 0, c_white, 1);

if flash_alpha > 0 {
	shader_set(sh_flash)
	draw_sprite_ext(sprite_index, image_index, x, y, facing, image_yscale, 0, flash_colour, flash_alpha)
	shader_reset();
}

if global.toggle_debug {
	// Draw the detection circle
	//draw_set_color(c_red);
	draw_circle(x, y, vision_range, true);

	// Draw the line to the player if within vision range
	if (point_distance(x, y, obj_player.x, obj_player.y - 22) <= vision_range) {
	    draw_set_color(c_yellow);
	    draw_line(x, y + vision_offset_y, obj_player.x, obj_player.y);
	}

	// Reset color
	draw_set_color(c_white);
}