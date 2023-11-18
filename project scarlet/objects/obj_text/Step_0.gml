//create at position so i can switch who the text is created above
player_x_dis = create_above .x;
player_y_dis = create_above .y - 50;



//get the length of the amount of pages in the dialogue (amount of total texts that will show up)
dialogue_length = array_length(game_dialogue)

if(ended) and input_check_pressed("accept"){
	obj_player.talking = false;
	instance_destroy();
}

//skip line animation if space pressed else turn page
if (typist.get_state() < 1 and input_check_pressed("accept")) typist.skip() else if (page != dialogue_length - 1 and input_check_pressed("accept")) page++;

