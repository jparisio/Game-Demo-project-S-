instance_create_layer(x , y, "Instances", obj_explosion);
create_shake();
// Number of shrapnel pieces and angle increment
var num_pieces = 5;
var angle_increment = 180 / (num_pieces - 1); // 36 degrees

// Create shrapnel pieces
for (var i = 0; i < num_pieces; i++) {
    // Calculate the angle for each piece
    var angle = i * angle_increment;
    
    // Create the shrapnel at the grenade's position
    var shrapnel = instance_create_layer(x, y - 8, "Instances", obj_shrapnel);
    
    // Set the movement direction of the shrapnel
    shrapnel.speed = 5;
	shrapnel.direction = angle;
	shrapnel.image_angle = angle - 90;
}
