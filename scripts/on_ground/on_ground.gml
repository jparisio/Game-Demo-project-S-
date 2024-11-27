// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function on_ground(_inst){
	if place_meeting(_inst.x, _inst.y + 1, obj_wall_parent){
		return true;
	}
	
	var _one_way = instance_place(_inst.x, _inst.y + max(1, _inst.vsp), obj_one_way_plat);
	if _one_way != noone {
	if _inst.bbox_bottom < _one_way.bbox_bottom && _inst.vsp >= 0
		{
			return true;
		}
		
	}
	
	
	
	return false
}