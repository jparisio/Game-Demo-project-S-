function CutsceneController() constructor
{
    cutscene_active = false;
    cutscene_index = 0;
    cutscene_timer = 0;
    cutscene_actions = [];
	global.cutscene_ended = false;
    
    // Start the cutscene
    StartCutscene = function(_actions) {
        cutscene_active = true;
        cutscene_index = 0;
        cutscene_timer = 0;
        cutscene_actions = _actions;
    }

    // Move to the next action
    NextAction = function() {
        cutscene_index += 1;
    }

    // Update the cutscene state
    Update = function() {
        if (cutscene_active && cutscene_index < array_length(cutscene_actions)) {
            var current_action = cutscene_actions[cutscene_index];
            current_action.Execute(self);  // Call Execute on the current action
        } else {
            cutscene_active = false;  // End of cutscene
			global.cutscene_ended = true;
        }
    }
}

