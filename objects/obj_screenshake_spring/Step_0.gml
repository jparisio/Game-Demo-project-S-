// Gradually reduce shake power (damping effect)
shakePow *= 0.9; // Damping factor, adjust 0.9 to control shake decay speed

// Introduce slight randomization to the shake angle for more natural shake
//shakeAng += random_range(-10, 10);

// Calculate the shake offsets based on current shake power and angle
shakeX = lengthdir_x(shakePow, shakeAng);
shakeY = lengthdir_y(shakePow, shakeAng);

// Apply the shake to the camera's position
obj_camera.x += shakeX;
obj_camera.y += shakeY;

// Optional: Stop shaking when the shake power is minimal
if (shakePow < 0.1) {
    shakePow = 0; // Stop shaking when the shake is almost negligible
}
