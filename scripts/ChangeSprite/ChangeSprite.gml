function ChangeSprite(_object, _sprite) : CutsceneAction("wait") constructor
{
    //action_parent = new CutsceneAction("wait");
    object = _object;
	sprite = _sprite;

    // Define the method as a variable
    Execute = function(_controller) {
       object.sprite_index = sprite;
	   object.image_index = 0;
	    object.image_speed = 1;
	   _controller.NextAction();
	}
	   
}
