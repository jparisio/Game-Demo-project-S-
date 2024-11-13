add_bullet(bullet);


//wave up and down
y += sin(sin_wave * .05) * .2;
//rotate left and right
image_angle += cos(sin_wave * .05) * .2;
sin_wave++;