// Spacing between points
point_spacing = 5;

// Number of points in the wave
num_points = round(sprite_width/point_spacing);

// Calculate total width of the wave
var total_wave_width = (num_points - 1) * point_spacing;

// Calculate the starting x-position to center the wave
start_x_position = x

// Base y-position of the wave (rest position)
base_y_position = y

// Spring constant and damping factor
spring_constant = 0.05;
damping = 0.98;

// Spread factor for wave propagation
spread = 0.2

//magnitude at contact point
magnitude = 2;

// Initialize the array of points
points = array_create(num_points);

for (var i = 0; i < num_points; i++) {
    points[i] = {
		x_position: start_x_position + i * point_spacing, 
        y_current: base_y_position,
        y_rest: base_y_position,
        velocity: 0,
		force_applied: false,
		player_colliding: false
    };
}
