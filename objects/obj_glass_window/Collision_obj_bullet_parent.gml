
image_index = 1;
mask_index = spr_empty;
//create glass shards
create_shake();
audio_play_sound(snd_glass_shatter, 3, 0, 1.3, 0, 1.1);
repeat(60) {
	var _x = random_range(x, x + sprite_width);
	var _y = random_range(y, y + sprite_height);
	var _shard = instance_create_layer(_x, _y, "Instances", obj_glass_shard);
	_shard.hspeed = random_range(8, 11) * obj_player. facing;
	_shard.vspeed = random_range(2, 7);
	_shard.gravity = 0.2;
}




