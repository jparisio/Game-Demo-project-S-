pause_toggle = 0;
reload_room = 0;

fsm = new SnowState("play")

fsm 

	.add("play", {
		
			enter: function(){
				//switch back to last state everything was in and skip their enter functions
			},
		
			step: function(){
				if pause_toggle fsm.change("paused");
				if reload_room fsm.change("reload room");
			}
	})
	
	.add("paused", {
		
			enter: function(){
				//switch player and all enemies to paused state
				with(obj_player) {
					fsm.change("paused");
				}

			},
		
			step: function(){
				if pause_toggle fsm.change("play");
			}
	})
	
	.add("room transition", {
		
			enter: function(){
				//switch player and all enemies to paused state

			},
		
			step: function(){

			}
	})
	
	.add("reload room", {
		
			enter: function(){
				instance_create_layer(x, y, "Lighting", obj_reset_room_transition);

			},
		
			step: function(){
				if !instance_exists(obj_reset_room_transition) fsm.change("play");
			}
	});