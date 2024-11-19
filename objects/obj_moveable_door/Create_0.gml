//target = noone

fsm = new SnowState("start");

  fsm	
  
  .add("start", {
		enter: function() {
			
		},
		step: function() {
			
			if target != noone {
				if target.hit fsm.change("end");
			}
		}
		
 })
 
 
   	.add("end", {
		enter: function() {
			mask_index = spr_empty;
			sprite_index = spr_empty;
			
		},
		step: function() {
			
		
		}
		
 });


