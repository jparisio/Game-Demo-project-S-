add_bullet(bullet);


//wave up and down
y += sin(sin_wave * .05) * .1;
//rotate left and right
image_angle += cos(sin_wave * .05) * .1;
sin_wave++;