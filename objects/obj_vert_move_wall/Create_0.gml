start_y = y;
dest_y = y - 100;
_speed = 0;
prev_speed = 0;

rest_timer_max = 120;
rest_timer = rest_timer_max;

fsm = new SnowState("start");

  fsm	
  
  .add("start", {
		enter: function() {
			rest_timer = rest_timer_max / 2
			
		},
		step: function() {
			rest_timer --
			if rest_timer <=0 fsm.change("move");
		
		}
		
 })
 
 
   	.add("move", {
		enter: function() {
			_speed = -13
			
		},
		step: function() {
			
			if(abs(dest_y - y) >= abs(_speed * 2)){
				//with(obj_player){
				//	if place_meeting(x, bbox_bottom, other) stored_velocity = -3;
				//}
			}
			
			if(abs(dest_y - y) >= abs(_speed)){
				 y += _speed;
			 } else {
				 fsm.change("rest")
			 }
		
		}
		
 })
 
    .add("rest", {
		enter: function() {
			rest_timer = rest_timer_max
			//with(obj_player){
			//		if place_meeting(x, bbox_bottom, other) stored_velocity = -3;
			//	}
		},
		step: function() {
			
			rest_timer--
			if rest_timer <=0 fsm.change("return");
		
		}
		
 })
 
   	.add("return", {
		enter: function() {
			_speed = 4;
			
		},
		step: function() {
			
			 if(abs(start_y - y) >= _speed){
				 y += _speed;
			 } else {
				 fsm.change("start")
			 }
		
		}
		
 });


