// Step 1: Define the circle properties
center_x = obj_player.x; // Use the player's x position as the center
center_y = obj_player.y; // Use the player's y position as the center
radius = 200;
max_radius = 300;
num_rockets = 10;

// Step 2: Create the rockets in a loop
for (var i = 0; i < num_rockets; i++) {
    // Calculate the angle for this rocket
    var angle = i * (360 / num_rockets);
    
    // Convert the angle to radians
    var radian_angle = degtorad(angle);
    
    // Calculate the rocket's initial position
    var x_pos = center_x + lengthdir_x(max_radius, angle);
    var y_pos = center_y + lengthdir_y(max_radius, angle);
    
    // Create the rocket instance at the calculated position
    var _rocket = instance_create_layer(x_pos, y_pos, "Instances", obj_rocket);
    
    // Step 3: Set the rocket's direction and initial speed
    _rocket.direction = angle;
    _rocket.speed = 0; // Initial speed, will be updated later
	_rocket.target_angle = angle;
	_rocket.move_speed = i + 1 * 2;
}

