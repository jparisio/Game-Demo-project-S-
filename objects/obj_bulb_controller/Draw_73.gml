///Draw End Event for objLightController
var vx = obj_camera.x - global.cam_width * global.x_offset
var vy = obj_camera.y - global.cam_height * global.y_offset
renderer.Update(vx, vy,  global.cam_width, global.cam_height);
renderer.Draw(vx, vy);