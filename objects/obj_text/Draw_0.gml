/////Draw

////create box rectangle (a lot of this is really slopppy math)
//draw_set_color(c_black)
//var _height = string_height_scribble_ext(game_dialogue[page], max_width); 
//var _width = string_width_scribble(game_dialogue[page]);
//_width = clamp(_width, 0, max_width)
////smoothly reveal the whole box
//rec_height = lerp(rec_height, _height - (_height), 0.3); 
//rec_width = lerp(rec_width, _width + 5 - (_width/2), 0.3); //adding 5 so that the padding is even and shifting to the length
//var _x1 = player_x_dis - (_width/2) - 7;// the minus 7 is for padding
//var _y1 = player_y_dis - (_height) - 3;
//var _x2 = player_x_dis + rec_width;
//var _y2 = player_y_dis + rec_height;
//draw_roundrect_ext(_x1, _y1, _x2, _y2, 4 , 4,  false) 

////create a little triangle for speech bubble in the centre if text is larger or bottom left if its smaller
//if _width >= max_width - 50 draw_triangle(_x1 + (_width/2), _y2, _x1 + (_width/2) + 4, _y2, (_x1 + (_width/2) + _x1 + (_width/2) + 4)/2, _y2 + 2, false)
//else draw_triangle(_x1 + 3, _y2, _x1 + 7, _y2, (_x1 + 3 + _x1 + 7)/2, _y2 + 2, false);

////create text
//scribble(game_dialogue[page]).wrap(max_width).draw(player_x_dis - (_width/2), player_y_dis - (_height), typist) //some horrible math to shift the text depending on the length of the text


