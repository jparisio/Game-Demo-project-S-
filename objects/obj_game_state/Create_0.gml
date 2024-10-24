game_state = new SnowState("play")

game_state 

	.add("play", {
		
			enter: function(){


			},
		
			step: function(){

			}
	})
	
	.add("paused", {
		
			enter: function(){
				//switch player and all enemies to paused state

			},
		
			step: function(){

			}
	})
	
	.add("reload room", {
		
			enter: function(){


			},
		
			step: function(){

			}
	});