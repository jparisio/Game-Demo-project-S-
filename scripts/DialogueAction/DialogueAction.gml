function DialogueAction(_create_above, _text_id) : CutsceneAction("Dialogue") constructor
{
    create_above = _create_above;
	text_id = _text_id;
	text_created = false;

    // Define the method as a variable
    Execute = function(_controller) {
		if(!text_created){
			text_created = true;
			var text_box = instance_create_layer(create_above.x, create_above.y, "Instances", obj_text)
			text_box.current_dialogue_id = text_id;
			text_box.create_above = create_above;
		}
		
		//move to next when done
		if(!instance_exists(obj_text)){
			_controller.NextAction();
			text_created = false;
		}
    }
}
