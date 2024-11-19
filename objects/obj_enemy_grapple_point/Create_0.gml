event_inherited();


hp = 1;
fsm = new SnowState("start")


fsm

	.add("start", {
		enter: function(){
			self_grapple = create_grapple_target(self, x, y, 0, 200);
			image_index = 0;
			
		},
		
		step: function(){
			if hp <=0 fsm.change("dead");
			
		}
		
		
	})
	
	
	.add("dead", {
		enter: function(){
			create_sparks(x, y);
			image_index = 1;
			remove_grapple_target(self_grapple);
			instance_destroy(self_grapple);
			self_grapple = noone;
			
		},
		
		step: function(){
			
			
		}
		
		
	});



