function MoveAction(_object, _target_x, _target_y, _speed) : CutsceneAction("move") constructor
{
	
	show_debug_message(type)
    object = _object;
    target_x = _target_x;
    target_y = _target_y;
    speed = _speed;
	start_moving = true;

    // Override execute method
    Execute = function(_controller) {
		
		//ensure we are actually moving (a weird bug with the other play anim part makes this weird
		object.image_speed = 1 * global.game_speed;
		
		with(object){
			
			//update the direction facing
			if(speed != 0) facing = sign(speed);
			
			//anims
			if(other.start_moving){
				sprite_index = spr_idle_to_run;
				other.start_moving = false;
			}
			
			if(sprite_index == spr_idle_to_run and animation_end()){
				sprite_index = spr_run;
				image_index = 0;
			}
			
			if(sprite_index == spr_run and abs(speed) <= 0.5){
				sprite_index = spr_run_to_idle;
				image_index = 0;
			}
			
			if(sprite_index == spr_run_to_idle and animation_end()){
				sprite_index = spr_idle;
				image_index = 0;
			}
			
		}
		
        if (point_distance(object.x, object.y, target_x, target_y) > speed) {
            var dir = point_direction(object.x, object.y, target_x, target_y);
            object.x += lengthdir_x(speed, dir);
            object.y += lengthdir_y(speed, dir);
        } else {
            _controller.NextAction();
			//reset flag for repeat usage
			start_moving = true;
        }
    }
}
