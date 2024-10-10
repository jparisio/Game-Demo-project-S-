//// Get the display dimensions
//var display_width = fullscreen? display_get_width() : window_get_width();
//var display_height = fullscreen? display_get_height() : window_get_height();

//// Get the camera dimensions
//var cam_width = global.cam_width;
//var cam_height = global.cam_height;

//// Calculate aspect ratio
//var display_ratio = display_width / display_height;
//var cam_ratio = cam_width / cam_height;

//// If display aspect is wider, scale by height
//if (display_ratio > cam_ratio) {
//    global.app_ratio_y = display_height / cam_height;
//    global.app_ratio_x = global.app_ratio_y;
//} else { // If taller, scale by width
//    global.app_ratio_x = display_width / cam_width;
//    global.app_ratio_y = global.app_ratio_x;
//}

//// Center the camera view
//var offset_x = (display_width - cam_width * global.app_ratio_x) / 2;
//var offset_y = (display_height - cam_height * global.app_ratio_y) / 2;

//// Draw scaled camera view
//draw_surface_ext(application_surface, offset_x, offset_y, global.app_ratio_x, global.app_ratio_y, 0, c_white, 1);
