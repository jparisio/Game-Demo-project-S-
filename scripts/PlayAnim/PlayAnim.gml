function PlayAnim(target_object, _anim) : CutsceneAction("play anim") constructor
{
    anim = _anim;
    object = target_object;
	anim_started = false;
	anim_ended = false;

    // Define the Execute method
    Execute = function(_controller) {
        // Set the sprite index and initialize other properties
		if(!anim_started){
			anim_started = true;
	        object.sprite_index = anim;  // Set the sprite index when executing
	        object.image_index = 0;       // Reset the image index to start the animation
	        object.image_speed = 1 * global.game_speed; // Set image speed
		}

        // Check if the animation has ended
		with(object){
	        if (animation_end()) {
				//stop the anim MAKE THIS THIS DOESNT CAUSE BUGS LATER
	            image_speed = 0;
	            other.anim_ended = true;
	        }
		}
		//switch to next state if anim ended
		if(anim_ended){
			_controller.NextAction(); // Correctly reference the controller
			//reset these 
			anim_started = false;
			anim_ended = false;
		}
    }
}

