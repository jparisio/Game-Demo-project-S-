// Function to calculate Catmull-Rom spline points
function catmull_rom_spline(p0, p1, p2, p3, t) {
    var t2 = t * t;
    var t3 = t2 * t;
    
    var _x = 0.5 * ((2 * p1[0]) +
                    (-p0[0] + p2[0]) * t +
                    (2 * p0[0] - 5 * p1[0] + 4 * p2[0] - p3[0]) * t2 +
                    (-p0[0] + 3 * p1[0] - 3 * p2[0] + p3[0]) * t3);
                    
    var _y = 0.5 * ((2 * p1[1]) +
                    (-p0[1] + p2[1]) * t +
                    (2 * p0[1] - 5 * p1[1] + 4 * p2[1] - p3[1]) * t2 +
                    (-p0[1] + 3 * p1[1] - 3 * p2[1] + p3[1]) * t3);
    
    return [_x, _y];
}

// Draw the smooth line using Catmull-Rom splines
draw_set_color(c_white);
draw_set_alpha(1);

// Begin drawing a line strip primitive
draw_primitive_begin(pr_linestrip);

// Define how many points to generate between each pair of points
var segments = 10; // Adjust for smoother or rougher curves

// Iterate over the points to draw the smooth curve
for (var i = 1; i < ds_list_size(point_array) - 2; i++) {
    var p0 = point_array[| i - 1];
    var p1 = point_array[| i];
    var p2 = point_array[| i + 1];
    var p3 = point_array[| i + 2];
    
    for (var j = 0; j <= segments; j++) {
        var t = j / segments;
        var point = catmull_rom_spline(p0, p1, p2, p3, t);
        draw_vertex(point[0], point[1]);
    }
}

draw_primitive_end();


//var thickness = 2; // Set the desired thickness
//var half_thickness = thickness / 2;

//// Begin drawing a triangle strip primitive
//draw_primitive_begin(pr_trianglestrip);

//for (var i = 0; i < ds_list_size(point_array); i++) {
//    var point = point_array[| i];
//    var next_point = point_array[| i + 1];

//    if (i < ds_list_size(point_array) - 1) {
//        var dir = point_direction(point[0], point[1], next_point[0], next_point[1]);
//        var perp_x = lengthdir_x(half_thickness, dir + 90);
//        var perp_y = lengthdir_y(half_thickness, dir + 90);

//        // Create two vertices for the triangle strip
//        draw_vertex(point[0] + perp_x, point[1] + perp_y);
//        draw_vertex(point[0] - perp_x, point[1] - perp_y);
//    }
//}

//draw_primitive_end();


//// Draw the line with smooth curves
//draw_set_color(c_white);
//draw_set_alpha(1);
//draw_primitive_begin(pr_linestrip);
//for (var i = 0; i < ds_list_size(point_array); i++) {
//    var point = point_array[| i];
//    draw_vertex(point[0], point[1]);
//}
//draw_primitive_end();

