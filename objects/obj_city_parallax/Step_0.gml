// Get the camera's current position
var cam_x = camera_get_view_x(view_camera[0]);
var cam_y = camera_get_view_y(view_camera[0]);

// Adjust layers for parallax in the opposite direction of the camera
layer_x("Parallax4", -cam_x * 0.01);
layer_y("Parallax4", -cam_y * 0.2);

layer_x("Parallax3", -cam_x * 0.01);
layer_y("Parallax3", -cam_y * 0.1);

layer_x("Parallax2", -cam_x * 0.01);
layer_y("Parallax2", -cam_y * 0.05);

layer_x("Parallax1", -cam_x * 0.01);
layer_y("Parallax1", -cam_y * 0.025);
