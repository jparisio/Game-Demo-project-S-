pause_toggle = 0;
reload_room = 0;
loaded_room = 0;
next_room = 0;
new_game = 0;

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
				if instance_exists(obj_player) instance_destroy(obj_player);
				if instance_exists(obj_cursor_controller) instance_destroy(obj_cursor_controller);
				if instance_exists(obj_player_gui) instance_destroy(obj_player_gui);
				if instance_exists(obj_bullet_ui) instance_destroy(obj_bullet_ui);
				new_game = false;
			},
		
			step: function(){
				
			},
			
			leave: function(){
				instance_create_layer(x, y, "Player", obj_player);
				//instance_create_layer(x, y, "Cursor", obj_cursor_controller);
				//instance_create_layer(x, y, "UI", obj_player_gui);
				//instance_create_layer(x, y, "UI", obj_room_test);
				//instance_create_layer(x, y, "Lighting", obj_light_manager);
			}
	})
	
	.add("load game", {
		enter: function() {
			loaded_room = load_game_data();
			var new_room = asset_get_index(loaded_room.room);
			if new_game  room_goto(Room01); else room_goto(new_room);
		},
		step: function() {
			fsm.change("play");
		}
	});
	
	
	//set window to full screen 
	//window_set_fullscreen(true);