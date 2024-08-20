shakePowSp = lerp(shakePowSp, (0-shakePow) * 0.4, 0.6)
shakeX = lengthdir_x(shakePow, shakeAng);
shakeY = lengthdir_y(shakePow, shakeAng);


// Apply the shake to the camera's position
camera_set_view_pos(view_camera[0], obj_camera.x + shakeX, obj_camera.y + shakeY);

// Gradually reduce the shake power (damping effect)
shakePow *= 0.9;