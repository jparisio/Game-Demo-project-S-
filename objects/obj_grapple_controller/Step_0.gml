// Initialization
player_x = obj_player.x;
player_y = obj_player.y - 20;

if (mouse_check_button_pressed(mb_right)) {
    // Calculate the distance and direction to the mouse click position
    var dist = point_distance(player_x, player_y, mouse_x, mouse_y);
    var dir = point_direction(player_x, player_y, mouse_x, mouse_y);
    
    // Calculate the step size (spacing between points)
    var step_size = 8; // You can adjust this value

    // Clear the previous points
    ds_list_clear(point_array);
    
    // Create the points along the line
    for (var d = 0; d <= dist; d += step_size) {
        var _x = player_x + lengthdir_x(d, dir);
        var _y = player_y + lengthdir_y(d, dir);
        // Add initial velocity and other properties
        var point = [_x, _y, 0, _y]; // [x, y, velocity, rest_y]
        ds_list_add(point_array, point);
    }
    
    // Apply a magnitude to each point to make it jiggle
    var magnitude = 20; // Adjust the magnitude as needed
    for (var i = 0; i < ds_list_size(point_array); i++) {
        var point = point_array[| i];
        point[2] = magnitude * (irandom(1) * 2 - 1); // Random positive or negative velocity
        ds_list_replace(point_array, i, point);
    }
}

// Water wave spring mechanics
var spring_constant = 0.1; // Adjust as needed
var damping = 0.9; // Adjust as needed
var spread = 0.1; // Adjust to control how the wave spreads

// Update each point using the spring mechanics
for (var i = 0; i < ds_list_size(point_array); i++) {
    var point = point_array[| i];
    
    // Calculate the force based on Hooke's law
    var force = -spring_constant * (point[1] - point[3]); // point[3] is the rest_y
    
    // Update the velocity and apply damping
    point[2] += force;
    point[2] *= damping;
    
    // Update the current y-position
    point[1] += point[2];
    
    // Store the updated point back in the ds_list
    ds_list_replace(point_array, i, point);
}

// Propagate the wave to neighboring points
for (var i = 1; i < ds_list_size(point_array) - 1; i++) {
    var point_prev = point_array[| i - 1];
    var point = point_array[| i];
    var point_next = point_array[| i + 1];
    
    // Apply wave spread along the angle
    var wave_effect_prev = (point[1] - point_prev[1]) * spread;
    var wave_effect_next = (point[1] - point_next[1]) * spread;
    
    point_prev[1] += wave_effect_prev;
    point_next[1] += wave_effect_next;
    
    // Store the updated points back in the ds_list
    ds_list_replace(point_array, i - 1, point_prev);
    ds_list_replace(point_array, i + 1, point_next);
}
