function create_enemy_grapple_target(_follow, _x, _y, _offset, _radius = 140, grapple_scale = 1, _creator = "enemy"){
	var grap_point = instance_create_layer(_x, _y, "Instances", obj_grapple_point);
	grap_point.creator = _creator;
	grap_point.follow = _follow;
	grap_point.offset = _offset;
	grap_point.radius = _radius;
	grap_point.image_xscale = grapple_scale;
	grap_point.image_yscale = grapple_scale;
	grap_point.visible = false;
	
}