if follow != noone {
	x +=  (follow.x - x)/25;
	y += (follow.y - y)/30;
	//follow only at if moving up greater distances
	//if(abs(follow.y - y) >= 25 or obj_player.on_ground) y += (follow.y - y)/30
}
//move the camera offset depending on if the player is facing left or right
if(obj_player.facing == 1){
	global.x_offset = lerp(global.x_offset, 0.35, 0.0025);
} else {
	global.x_offset = lerp(global.x_offset, 0.65, 0.0025);
}
var _x =  x - global.cam_width * global.x_offset;
var _y = y - global.cam_height * global.y_offset;

//clamp the x and y 
x = clamp(x, 100, 1520);
y = clamp(y, 260 , 270);

camera_set_view_pos(view_camera[0], _x, _y);
camera_set_view_size(view_camera[0],global.cam_width, global.cam_height);

if (snap_to){
	x = obj_player.x;
	y = obj_player.y;
	snap_to = false;
}