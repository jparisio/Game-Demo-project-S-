var cam = camera_get_view_x(view_camera[0])
layer_x("Buildings_close", cam * 0.05);
layer_x("Buildings_mid", cam * 0.1);
layer_x("Buildings_far", cam * 0.2);
layer_x("Clouds", cam * 0.3);
