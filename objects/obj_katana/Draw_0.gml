draw_self();

// Get the start and end points
var startX = x;
var startY = y;
var endX = obj_player.x;
var endY = obj_player.y - 30;

// Calculate the distance between the katana and the player
var distance = point_distance(startX, startY, endX, endY);

// Determine the number of segments based on the distance
var segments = max(10, distance / 10); // Example: one segment every 10 pixels

var amplitude = 5; // Amplitude of the wave (how much it wobbles)
var frequency = 0.1; // Frequency of the wave

// Calculate the direction and step for each segment
var dx = (endX - startX) / segments;
var dy = (endY - startY) / segments;

// Begin drawing the primitive
draw_primitive_begin(pr_trianglestrip);
draw_set_color(c_white);

// Draw the wavy line using triangle strip for smoothness
for (var i = 0; i <= segments; i++) {
    var t = i / segments;
    var waveY = amplitude * sin(i * frequency * 2 * pi); // Sine wave for the y-offset

    var x1 = startX + i * dx;
    var y1 = startY + i * dy + waveY;

    // Calculate the perpendicular offset for the triangle strip
    var perpendicular_offset = 5; // Adjust this for thickness
    var normal_x = -dy / distance;
    var normal_y = dx / distance;

    // Top point
    draw_vertex(x1 + normal_x * perpendicular_offset, y1 + normal_y * perpendicular_offset);

    // Bottom point
    draw_vertex(x1 - normal_x * perpendicular_offset, y1 - normal_y * perpendicular_offset);
}

// End drawing the primitive
draw_primitive_end();
