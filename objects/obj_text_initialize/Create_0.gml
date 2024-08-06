//ended func
end_text = function(){
	obj_text.ended = true
}

//choose what object to create he speech bubble above
speech_bubble_target = function(_element, _parameter_array, _character_index){
	var _t = asset_get_index(string_trim(_parameter_array[0]))
	obj_text.create_above = _t; 
}


//add the shake event
scribble_typists_add_event("shake_screen", create_shake);
scribble_typists_add_event("ended", end_text);
scribble_typists_add_event("switch", speech_bubble_target);

//set fonts
scribble_font_set_default("text_font");
scribble_font_scale("text_font", .5)