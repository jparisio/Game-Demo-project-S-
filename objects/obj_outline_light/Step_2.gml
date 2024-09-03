if(follow != noone){

	light.x = follow.x;
	light.y = follow.y;
	light.blend = colour;
	light.xscale = xscale;
	light.yscale = yscale;
	light.angle = follow.image_angle;
	light.sprite = sprite;
}

if(!instance_exists(follow)){
	instance_destroy();
}