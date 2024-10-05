function DestroyAction(_target_object) : CutsceneAction("destroy") constructor
{
	
	target_object = _target_object;

    // Define the Execute method
    Execute = function(_controller) {
		if(instance_exists(target_object)){
			instance_destroy(target_object);
		}
		
		_controller.NextAction();
    }
}

