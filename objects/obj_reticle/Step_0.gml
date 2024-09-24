if(stop and !remove){
	remove = true;
	create_hitbox("boss", self, x, y, 1, spr_crosshair_hurtbox, 3, 15);
	audio_play_sound(snd_gunshot, 1, 0);
	create_shake();
}

if(!stop){
	x = lerp(x, obj_player.x, rand);
	y = lerp(y, obj_player.y - 40, rand);
}

if remove {
	life--;
}


if life <= 0 instance_destroy();


//lerp the size back to noraml
image_xscale = lerp(image_xscale, 1, 0.1);
image_yscale = lerp(image_yscale, 1, 0.1);