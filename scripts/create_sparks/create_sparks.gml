// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function create_sparks(_x, _y, _min = 6, _max = 15){
	repeat(15) {
		var _speed = random_range(_min, _max)
		var spark = instance_create_layer(_x, _y, "Instances", obj_sparks);
		spark.speed = _speed
	}
}