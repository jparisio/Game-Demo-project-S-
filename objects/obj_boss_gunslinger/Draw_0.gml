draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * facing, image_yscale, 0, image_blend, image_alpha)

if flash_alpha > 0 {
	shader_set(sh_flash)
	draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * facing, image_yscale, 0, flash_colour, flash_alpha)
	shader_reset();
}