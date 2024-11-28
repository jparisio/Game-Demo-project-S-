pause_toggle = 0;
reload_room = 0;

fsm = new SnowState("main menu")

fsm 

	.add("play", {
		
			enter: function(){
				//switch back to last state everything was in and skip their enter functions
			},
		
			step: function(){
				if pause_toggle fsm.change("paused");
				if reload_room fsm.change("reload room");
				if (instance_exists(obj_player)){
					if obj_player.fsm.get_current_state() == "injured" fsm.change("reload room");
				}
			}
	})
	
	.add("paused", {
		
			enter: function(){
				

			},
		
			step: function(){
				if pause_toggle fsm.change("play");
			}
	})
	
	.add("room transition", {
		
			enter: function(){
				if (room_next(room) != -1){
					var _trans = instance_create_layer(x, y, "Lighting", obj_reset_room_transition);
					_trans.next_room = true;
				}
			},
		
			step: function(){
				fsm.change("play")
			}
	})
	
	.add("reload room", {
		
			enter: function(){
				var _trans = instance_create_layer(x, y, "Lighting", obj_reset_room_transition);
				_trans.reset = true;

			},
		
			step: function(){
				if !instance_exists(obj_reset_room_transition) fsm.change("play");
			}
	})
	
	.add("main menu", {
		
			enter: function(){
				//instance_create_layer(x, y, "Instances", obj_menu_parent);
			},
		
			step: function(){
				
			},
			
			leave: function(){
				instance_create_layer(x, y, "Player", obj_player);
				instance_create_layer(x, y, "Cursor", obj_cursor_controller);
				instance_create_layer(x, y, "UI", obj_player_gui);
				//instance_create_layer(x, y, "UI", obj_room_test);
				//instance_create_layer(x, y, "Lighting", obj_light_manager);
			}
	});
	
	
	//set window to full screen 
	window_set_fullscreen(true);