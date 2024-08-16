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
//index = 0;
page = 0;
dialogue_length = 0;
//script
game_dialogue[0] = ""
//dialogue
//game_script("test");

// Load the JSON file
// Create Event

// Create Event

// Load the JSON file
var json_string = file_text_open_read("dialogue.json");
var json_content = "";
while (!file_text_eof(json_string)) {
    json_content += file_text_read_string(json_string);
    file_text_readln(json_string);
}
file_text_close(json_string);

// Parse the JSON string into a struct
dialogue_data = json_parse(json_content);

//Store the current dialogue ID
current_dialogue_id = "";


//box
rec_width = 0;
rec_height = 0;

//player distance
create_above = undefined;
player_x_dis = 0;
player_y_dis = 0;

//max width
max_width = 130;
