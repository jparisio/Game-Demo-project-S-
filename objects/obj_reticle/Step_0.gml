
if(!stop){
	x = lerp(x, obj_player.x, rand);
	y = lerp(y, obj_player.y - 40, rand);
}

if stop {
	life--;
}


if life <= 0 instance_destroy();


//lerp the size back to noraml
image_xscale = lerp(image_xscale, 1, 0.1);
image_yscale = lerp(image_yscale, 1, 0.1);