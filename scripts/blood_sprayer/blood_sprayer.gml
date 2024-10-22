// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function blood_sprayer(create_at, _angled = noone){
		var sprayer = instance_create_layer(create_at.x, create_at.y, "Instances", obj_blood_sprayer);
	    sprayer.create_at = create_at
		sprayer.facing = obj_player.facing;
		sprayer.angle = _angled
}