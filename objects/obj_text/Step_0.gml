//create at position so i can switch who the text is created above
if(create_above != undefined){
	player_x_dis = create_above .x;
	player_y_dis = create_above .y - 50;
}

// Step Event

if (dialogue_data != undefined) {
    //show_debug_message(struct_exists(dialogue_data, current_dialogue_id));
	
	if(struct_exists(dialogue_data, current_dialogue_id)){
		var data = struct_get(dialogue_data, current_dialogue_id);
		for(var i = 0; i < array_length(data); i++){
			game_dialogue[i] = data[i];
		}
		//show_debug_message(data);
	} else {
	    var data = -1;
	}
	
	//show_debug_message(dialogue_data);
}



//get the length of the amount of pages in the dialogue (amount of total texts that will show up)
dialogue_length = array_length(game_dialogue);

if(ended) and input_check_pressed("accept"){
	obj_player.talking = false;
	instance_destroy();
}

//skip line animation if space pressed else turn page
if (typist.get_state() < 1 and input_check_pressed("accept")) typist.skip() else if (page != dialogue_length - 1 and input_check_pressed("accept")) page++;


//if create_above == obj_boss_gunslinger {
//	typist.sound_per_char([snd_error], .7, .9, [""], .6);
//} else {
//		typist.sound_per_char([snd_speak4], .7, .1, [""], .6);
//}