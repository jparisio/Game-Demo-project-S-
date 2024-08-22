/////Draw End Event for objLightController
//can do this way
//var vx = obj_camera.x - global.cam_width * global.x_offset
//var vy = obj_camera.y - global.cam_height * global.y_offset
//renderer.Update(vx, vy,  global.cam_width, global.cam_height);
//renderer.Draw(vx, vy);

//this way is much cleaner
renderer.UpdateFromCamera(view_camera[0]);
renderer.DrawOnCamera(view_camera[0], 1);