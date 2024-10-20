// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function remove_grapple_point(grapple_point){
	var _i = ds_list_find_index(obj_player.grapple_target_list, grapple_point);
	ds_list_delete(obj_player.grapple_target_list, _i);
	obj_player.can_grapple = false;
}