
// Set draw color for the fill with alpha
var fill_color = #1CA3EC;
var fill_alpha = 0.5; // Set the opacity (0.0 is fully transparent, 1.0 is fully opaque)
draw_set_color(fill_color);
draw_set_alpha(fill_alpha);

// Begin drawing the triangle list primitive
draw_primitive_begin(pr_trianglelist);

// Draw the triangles to create the filled area underneath the points
for (var i = 0; i < num_points - 1; i++) {
    var x1 = points[i].x_position;
    var y1 = points[i].y_current;
    var x2 = points[i + 1].x_position;
    var y2 = points[i + 1].y_current;
    
    // Bottom y position for the fill
    var bottom_y = base_y_position + sprite_height; // Or any other value to specify how far down the fill should extend
    
    // Draw two triangles for each segment of the wave line
    draw_vertex(x1, y1);          // Top-left vertex
    draw_vertex(x2, y2);          // Top-right vertex
    draw_vertex(x1, bottom_y);    // Bottom-left vertex
    
    draw_vertex(x2, y2);          // Top-right vertex
    draw_vertex(x1, bottom_y);    // Bottom-left vertex
    draw_vertex(x2, bottom_y);    // Bottom-right vertex
}

// End drawing the primitive
draw_primitive_end();

// Begin drawing the line strip primitive
draw_primitive_begin(pr_linestrip);

// Loop through the points and add them to the primitive
for (var i = 0; i < num_points; i++) {
    var x_pos = points[i].x_position;
    var y_pos = points[i].y_current;
    
    // Add the point to the primitive
    draw_vertex(x_pos, y_pos);
}

// End drawing the primitive
draw_primitive_end();


draw_set_alpha(1);
