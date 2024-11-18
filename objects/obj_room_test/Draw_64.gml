// Draw GUI Event
draw_set_color(c_white);
draw_set_font(font);

var input_box_x = 10;
var input_box_y = 0;
var input_box_width = 200;
var input_box_height = 40;

// Draw input box background
draw_rectangle(input_box_x, input_box_y, input_box_x + input_box_width, input_box_y + input_box_height, false);

draw_set_color(c_black);
// Draw input text
draw_text(input_box_x + 10, input_box_y + 10, "Room Index: " + input_number);

// Draw error message if any
if (error_message != "") {
    draw_text(input_box_x, input_box_y - 20, error_message);
}
