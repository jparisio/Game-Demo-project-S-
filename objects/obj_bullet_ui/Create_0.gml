draw_x = 0;
draw_y = 0;
index = 0;
bullet_sprite = noone;
sprite = spr_flame;
distort_sprite	= spr_flame_distortion_map;
distort_tex		= sprite_get_texture(distort_sprite, 0);

shader			= sh_flame_distortion;
u_distort_tex	= shader_get_sampler_index(shader, "distort_tex");
u_time			= shader_get_uniform(shader, "time");
u_strength		= shader_get_uniform(shader, "strength");
u_size			= shader_get_uniform(shader, "size");
u_bend			= shader_get_uniform(shader, "bend");

time			= random(1);
strength_x	= .231;		// [0, 0.3]
strength_y	= .5;		// [0, 1]
size		= .7;		// [0.25, 0.75]
bend		= -.5;		// [-1, +1]

//these are to shrink the flame out of sight when inactive
xscale = 1;
yscale = 1;


fsm = new SnowState("loaded")

	.add("loaded", {
	    enter: function() {
			xscale = 0;
			strength_y = -15;
	    },
	    step: function() {
	        if (index == obj_player.gun.get_index()) fsm.change("active");
	    }
		
	})
	

	
	.add("active", {
	    enter: function() {
			strength_y = -15;
	    },
	    step: function() {
			
			xscale = lerp(xscale, 1, .03);
	        
	        strength_y = lerp(strength_y, 0.5, 0.09);
			if (index < obj_player.gun.get_index()) fsm.change("inactive");
			if (index > obj_player.gun.get_index()) fsm.change("loaded");
	    }
		
	})
	
	
	.add("inactive", {
	    enter: function() {
			
	    },
	    step: function() {
			xscale = lerp(xscale, 0, .003);
	        strength_y = lerp(strength_y, -30, 0.002);
	        if (index >= obj_player.gun.get_index()) fsm.change("loaded");
	    }
		
	})



