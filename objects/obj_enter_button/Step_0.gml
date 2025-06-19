
if active == true and image_alpha <= 1 image_alpha += 0.08 else if active == false image_alpha -= 0.08
//image_alpha = clamp(image_alpha, 0, 1);

if image_alpha < 0 instance_destroy();

if input_check_pressed("action") instance_destroy();

//wave up and down
y += sin(sin_wave * .05) * .1;
x = create_above.x
//rotate left and right
image_angle += cos(sin_wave * .05) * .1;
sin_wave++;

