if (alarm >= 0) {
    shader_set(sh_chromatic_abb);
    var shader_params = shader_get_uniform(sh_chromatic_abb, "shake_val");
    shader_set_uniform_f(shader_params, global.shader_shake);
    
    // Draw the surface with the scaling factors
    draw_surface_ext(application_surface, 0, 0, global.app_ratio_x, global.app_ratio_y, 0, c_white, 1);
    
    shader_reset();
} else {
    // Always draw the application surface with the correct scaling
    draw_surface_ext(application_surface, 0, 0, global.app_ratio_x, global.app_ratio_y, 0, c_white, 1);
}
