// In Step Event of the trail object
image_alpha -=0.005;

if (image_alpha <= 0) {
    instance_destroy();  // Destroy the trail when fully transparent
}



