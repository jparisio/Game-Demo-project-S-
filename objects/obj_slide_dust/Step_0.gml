if animation_end() instance_destroy();



// You could also add a small speed and direction if you want it to keep floating over time
speed = random_range(0.5, 1.5); // Random slight speed
direction = random(360); // Random direction
gravity = .2;
gravity_direction = random(360);