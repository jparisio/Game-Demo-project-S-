#macro COLOUR_FOR_NO_MOVE make_colour_rgb(127,127,255)

// Get the sampler index for the distortion texture
distortion_stage = shader_get_sampler_index(sh_glass, "distortion_texture_page");

// Disable the automatic drawing of the application surface
application_surface_draw_enable(false);

