//states

fsm.step();

//apply mouse look
if (follow == obj_player) mouse_look();

//camera applying
var _x = x - global.cam_width * global.x_offset;
var _y = y - global.cam_height * global.y_offset;

//clamp to room boundaries
_x = clamp(_x, 0, room_width - global.cam_width);
_y = clamp(_y, 0, room_height - global.cam_height);


// Apply the camera position
camera_set_view_pos(view_camera[0], _x, _y);
camera_set_view_size(view_camera[0], global.cam_width, global.cam_height);

