//create scribble typist
typist = scribble_typist();
typist.in(.5, 5);
typist.character_delay_add(",", 100)
typist.character_delay_add(".", 150)

//moved these to initalize

//set font
//scribble_font_set_default("text_font");
//scribble_font_scale("text_font", .5)

//end text function
//end_text = function(){
//	ended = true
//}

////add the shake event
//scribble_typists_add_event("shake_screen", create_shake);
//scribble_typists_add_event("ended", end_text);

//vars
ended = false;
index = 0;
page = 0;
dialogue_length = 0;
//script
game_dialogue[0] = ""
//dialogue
//game_script("test");

//box
rec_width = 0;
rec_height = 0;

//player distance
create_above = obj_player
player_x_dis = create_above .x;
player_y_dis = create_above .y - 50;

//max width
max_width = 130;
