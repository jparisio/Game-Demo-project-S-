
if(create_at != noone){


if !sprayed {
	//to make it more like kzero, the way he does it is have an initial blood spray, 
	//then every frame creates some blood opposite of the direction the character is sliding at slighlty cahnging tis direction
	//then for the final bit, face the blood upwards and move slkightly left and right.  Ill do this eventually
	repeat(30) create_blood(facing, create_at.x -10, create_at .y-20)
	sprayed = true;
	
	initial_spray_direction = facing? 160: 30;
	current_spray_direction = initial_spray_direction;
}

if (sprayed) {

    // Calculate the new direction based on the frame count
    var target_direction = 90;
    var lerp_factor = clamp(frame_counter/spray_time , 0 , 1); // Gradually increase lerp_factor from 0 to 1 over 120 frames
    
	if(frame_counter >= spray_time) current_spray_direction = lerp(initial_spray_direction, target_direction, lerp_factor);

    // Create a blood instance every 3 frames
    if (frame_counter % 3 == 0) {
        // Create the blood instance at the specified position
        var blood_instance = instance_create_layer(create_at.x, create_at.y - 30, "Instances", obj_blood);

        // Set initial movement properties for the blood instance
        with (blood_instance) {
            speed = 3;  // Set the initial speed of the blood droplet

            // Increase the amplitude and adjust the frequency to exaggerate the spray
            var wave_amplitude = 30;  // Increased amplitude for more noticeable sine wave
            var wave_frequency = 0.2;  // Adjust frequency to control the speed of oscillation

            // Apply the sine wave to the direction and gradually adjust the spray direction
            direction = sin(other.frame_counter * wave_frequency) * wave_amplitude + other.current_spray_direction;

            // Apply gravity to make the blood droplet fall over time
            gravity = 0.09;
            gravity_direction = 270;
			image_angle = direction;
			// Set image_yscale based on direction
			if (direction > 90 && direction < 270) {
			    image_yscale = -1;  // Facing left
			} else {
			    image_yscale = 1;   // Facing right
			}
        }
    }

    // Increment the frame counter
    frame_counter++;
}

if(current_spray_direction == 90) death_time--;



}


if death_time <= 0 instance_destroy();