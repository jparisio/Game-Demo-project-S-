draw_sprite_ext(sprite_index, image_index, x, y, facing, image_yscale, 0, c_white, 1);

if flash_alpha > 0 {
	shader_set(sh_flash)
	draw_sprite_ext(sprite_index, image_index, x, y, facing, image_yscale, 0, flash_colour, flash_alpha)
	shader_reset();
}

// Define the three points of the triangle for the ray field
var triangle_x1 = x;  // The base of the triangle (enemy position)
var triangle_y1 = y + vision_offset_y;  // Apply the same offset to the base
var direction_to_player = facing? 0 : 180

/// Function to find the collision point along the line
/// Returns the distance to the collision point
function find_collision_point(x1, y1, x2, y2) {
    var precision = 1;  // Smaller number for more precise checking
    var dist = point_distance(x1, y1, x2, y2);
    var step = precision;
    
    // Step along the line and find the exact collision point
    repeat(dist / step) {
        var check_x = x1 + lengthdir_x(step, point_direction(x1, y1, x2, y2));
        var check_y = y1 + lengthdir_y(step, point_direction(x1, y1, x2, y2));
        if (collision_point(check_x, check_y, obj_wall, false, true)) {
            return point_distance(x1, y1, check_x, check_y);  // Return the distance to the collision point
        }
        step += precision;
    }
    
    // If no collision, return original distance (no obstacle)
    return dist;
}

// Define the base of the triangle (enemy's position)
var triangle_x1 = x;
var triangle_y1 = y + vision_offset_y;

// Calculate the original end points of the triangle without obstacles
var target_x2 = x + lengthdir_x(vision_range, direction_to_player - vision_angle / 2);
var target_y2 = y + vision_offset_y + lengthdir_y(vision_range, direction_to_player - vision_angle / 2);

var target_x3 = x + lengthdir_x(vision_range, direction_to_player + vision_angle / 2);
var target_y3 = y + vision_offset_y + lengthdir_y(vision_range, direction_to_player + vision_angle / 2);

// Check for wall collisions on the left side of the triangle
var dist_left = find_collision_point(x, y + vision_offset_y, target_x2, target_y2);
target_x2 = x + lengthdir_x(dist_left, direction_to_player - vision_angle / 2);
target_y2 = y + vision_offset_y + lengthdir_y(dist_left, direction_to_player - vision_angle / 2);

// Check for wall collisions on the right side of the triangle
var dist_right = find_collision_point(x, y + vision_offset_y, target_x3, target_y3);
target_x3 = x + lengthdir_x(dist_right, direction_to_player + vision_angle / 2);
target_y3 = y + vision_offset_y + lengthdir_y(dist_right, direction_to_player + vision_angle / 2);

// Set the triangle's color and transparency
draw_set_alpha(0.5);  // Semi-transparent
draw_set_color(c_yellow);  // Vision cone color

// Calculate the bounding rectangle
rec_min_x = min(triangle_x1, target_x2, target_x3);
rec_max_x = max(triangle_x1, target_x2, target_x3);
rec_min_y = min(triangle_y1, target_y2, target_y3);
rec_max_y = max(triangle_y1, target_y2, target_y3);

if(global.toggle_debug){
	// Draw the triangle with adjusted points if blocked by walls
	draw_triangle(triangle_x1, triangle_y1, target_x2, target_y2, target_x3, target_y3, false);
	// Draw the bounding rectangle (for visualization)
	draw_rectangle(rec_min_x, rec_min_y, rec_max_x, rec_max_y, false);
}


// Reset the alpha and color (to avoid affecting other draws)
draw_set_alpha(1);
draw_set_color(c_white);
