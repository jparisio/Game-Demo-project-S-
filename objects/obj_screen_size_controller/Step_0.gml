if (input_check_pressed("pause")) {
    // Toggle fullscreen mode
    fullscreen = !fullscreen;
    window_set_fullscreen(fullscreen);

    // Get the display and application surface dimensions
    var display_width = fullscreen? display_get_width() : window_get_width();
    var display_height = fullscreen? display_get_height() : window_get_height();
    var surface_width = surface_get_width(application_surface);
    var surface_height = surface_get_height(application_surface);
	
	//show_debug_message(fullscreen)
	//show_debug_message(display_width)
	//show_debug_message(display_height)

    // Calculate the scaling factors
    global.app_ratio_x = display_width / surface_width;
    global.app_ratio_y = display_height / surface_height;
	
	//show_debug_message(global.app_ratio_x)
	//show_debug_message(global.app_ratio_y)
} 


