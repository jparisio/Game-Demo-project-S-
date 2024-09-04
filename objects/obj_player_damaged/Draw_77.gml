
if alarm >= 0 {
	shader_set(sh_chromatic_abb);
	var shader_params = shader_get_uniform(sh_chromatic_abb, "shake_val");
	shader_set_uniform_f(shader_params, global.shader_shake);
	draw_surface(application_surface, 0, 0);
	shader_reset();
}