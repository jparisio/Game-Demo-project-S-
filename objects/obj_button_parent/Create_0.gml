val = 0;
val2 = 0;
hovering = false;
prev_scale = 0;
prev_angle = 0;

onClick = function() {};

fsm = new SnowState("not hovering");

fsm 

	.add("hovering", {
		enter: function(){
			val = 0;
			val2 = 0;
		},
		
		step: function(){
			if !hovering fsm.change("not hovering");
			val += 1 / 30;
			val = clamp(val, 0, 1);
	
			val2 += 1 / 15;
			val2 = clamp(val2, 0, 1);
    
			// Apply elastic animation curve to image scale
			var _scale = AnimcurveTween(1, 1.3, acElasticOut, val);
			image_xscale = _scale;
			image_yscale = _scale;
    
			// Apply elastic animation curve to rotation, oscillating around 0
			var _angle = AnimcurveTween(0, 3 * sin(val2 * 3 * pi), acElasticOut, val2); // wiggle left and right
			image_angle = _angle;
			
			if input_check_pressed("shoot") onClick();
		}
	})
	
	
	
	.add("not hovering", {
		enter: function(){
			val = 0;
			val2 = 0;
			prev_scale = image_xscale;
			prev_angle = image_angle;
		},
		
		step: function(){
			if hovering fsm.change("hovering");
			val += 1 / 30;
			val = clamp(val, 0, 1);
	
			val2 += 1 / 15;
			val2 = clamp(val2, 0, 1);
    
			// Apply elastic animation curve to image scale
			var _scale = AnimcurveTween(prev_scale, 1, acElasticOut, val);
			image_xscale = _scale;
			image_yscale = _scale;
    
			// Apply elastic animation curve to rotation, oscillating around 0
			var _angle = AnimcurveTween(prev_angle, 0 * sin(val2 * 3 * pi), acElasticOut, val2); // wiggle left and right
			image_angle = _angle;
		}
	})