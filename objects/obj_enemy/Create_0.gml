collide_and_move = function(){

vsp += grv;
//hori
	if place_meeting(x+hsp,y,obj_wall_parent) {
	    while !place_meeting(x+sign(hsp),y,obj_wall_parent) {
	        x += sign(hsp);
	    }
	    hsp = 0;
		//show_debug_message(sprite_get_name(mask_index))
	}
	x += hsp;

	//vert
	if place_meeting(x,y + vsp,obj_wall_parent) {
	    while !place_meeting(x,y+sign(vsp),obj_wall_parent) {
	        y += sign(vsp);
	    }
	    vsp = 0;
	}
	
	//one way
	var _one_way = instance_place(x, y + max(1, vsp), obj_one_way_plat);
	if _one_way != noone {
	if bbox_bottom < _one_way.bbox_bottom && vsp > 0
		{
		//stop moving or snap player to other.bbox_top eg.
		  y = _one_way.bbox_top - (bbox_bottom - y)
		  vsp = 0;
		}
		
	}
	
	y += vsp;

}

//determine facing script
determine_facing = function(){
	
	if(hsp != 0){
		facing = sign(hsp)
	}
}


self_grapple = noone;

hp = 0;

//hori and verti move
hsp = 0;
vsp = 0;
grv = .27;
//facing = 1;