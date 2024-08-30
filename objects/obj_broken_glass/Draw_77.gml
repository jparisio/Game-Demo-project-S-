// Create a surface for the distortion effect
surface_distort = surface_create(room_width, room_height);
surface_set_target(surface_distort);

// Clear the surface with a specific color and transparency
draw_clear_alpha(COLOUR_FOR_NO_MOVE, 0);

// Draw the distortion sprite or shapes on the surface
draw_sprite_ext(spr_broken_glass2, 0, 770, 201, 2, 1, 0, 1, 1);

// Reset the surface target to the application surface
surface_reset_target();

// Get the texture from the created surface
var surface_texture_page = surface_get_texture(surface_distort);

// Set the shader
shader_set(sh_glass);

// Set the distortion texture for the shader
texture_set_stage(distortion_stage, surface_texture_page);

// Draw the application surface with the distortion effect applied
draw_surface(application_surface, 0, 0);

// Reset the shader
shader_reset();

// Free the surface to prevent memory leaks
surface_free(surface_distort);

