
// Get the start and end points
var startX = x;
var startY = y;
var endX = obj_player.x;
var endY = obj_player.y - 30;

var distance = point_distance(startX, startY, endX, endY);
var _direction = point_direction(startX, startY, endX, endY);

//var amplitude = 5;
var frequency = 0.1;

// Calculate the number of segments based on the distance
var segments = max(10, distance / 10);

// Calculate the direction and step for each segment
var dx = (endX - startX) / segments;
var dy = (endY - startY) / segments;

// Begin drawing the primitive
draw_primitive_begin(pr_trianglestrip);
draw_set_color(c_white);

// Draw the wavy line using triangle strip for smoothness
for (var i = 0; i <= segments; i++) {
    var perpendicular_offset = .6;
    var wave = amplitude * sin(i * frequency * 2 * pi); // Sine wave

    var x1 = startX + i * dx + lengthdir_x(perpendicular_offset + wave, _direction + 90);
    var y1 = startY + i * dy + lengthdir_y(perpendicular_offset + wave, _direction + 90);
    
    var x2 = startX + i * dx + lengthdir_x(-perpendicular_offset + wave, _direction + 90);
    var y2 = startY + i * dy + lengthdir_y(-perpendicular_offset + wave, _direction + 90);

    // Top point
    draw_vertex(x1, y1);

    // Bottom point
    draw_vertex(x2, y2);
}

// End drawing the primitive
draw_primitive_end();


//draw_self();
