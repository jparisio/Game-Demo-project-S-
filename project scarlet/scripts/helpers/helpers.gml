function animation_hit_frame(frame){
	var frame_range = image_speed * sprite_get_speed(sprite_index) / game_get_speed(gamespeed_fps)
	return image_index >= frame and image_index < frame + frame_range;
}


function animation_end(){
    return (image_index + image_speed*sprite_get_speed(sprite_index)/(sprite_get_speed_type(sprite_index) == spritespeed_framespergameframe? 1 : game_get_speed(gamespeed_fps)) >= image_number);   
}

function create_hitbox(_creator, _x, _y, _facing, _sprite, _lifespan, _damage){
	var _hitbox = instance_create_layer(_x, _y, "Instances", obj_hitbox)
	_hitbox.sprite_index = _sprite;
	_hitbox.facing = _facing
	_hitbox.image_xscale = _facing;
	_hitbox.creator = _creator;
	_hitbox.lifespan = _lifespan;
	_hitbox.damage = _damage;

}


function create_blood(_facing, _x, _y, _angled){
	var _blood = instance_create_layer(_x, _y, "Instances", obj_blood)
	//random starting index
	_blood.image_index = random(5);
	//random lifetime 
	_blood.lifetime = random(12)
	_blood.image_speed = 1;
	//determine if the blood is angled or sideways
	if(_angled){	if sign(_facing) > 0 _blood.image_angle = random_range(20, 50) else _blood.image_angle = random_range( 120 , 150)}
	else { if sign(_facing) > 0 _blood.image_angle = random_range(30, 0) else _blood.image_angle = random_range( 160 , 190)}
	_blood.direction = _blood.image_angle;
	//speed
	_blood.speed = random_range(7, 10);
}

function hit_pause(_time){
	
	var _t = current_time + _time
	while(current_time <= _t){}
	
}

function create_shake(){
	instance_create_layer(x, y, "Instances", obj_screenshake_large)
}


function approach(_start, _end, _shift){

	/****************************************
	 Increments a value by a given shift but 
	 never beyond the end value
	 ****************************************/

	if (_start < _end)
	    return min(_start + _shift, _end); 
	else
	    return max(_start - _shift, _end);
	
}
