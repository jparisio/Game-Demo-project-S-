

function create_hitbox(_creator, _follow, _x, _y, _facing, _sprite, _lifespan, _damage, _yscale = 1){
	var _hitbox = instance_create_layer(_x, _y, "Instances", obj_hitbox)
	_hitbox.sprite_index = _sprite;
	_hitbox.facing = _facing
	_hitbox.image_xscale = _facing;
	_hitbox.image_yscale = _yscale;
	_hitbox.creator = _creator;
	_hitbox.lifespan = _lifespan;
	_hitbox.damage = _damage;
	_hitbox.follow = _follow;

}


//function create_blood(_facing, _x, _y, _angled){
//	var _blood = instance_create_layer(_x, _y, "Instances", obj_blood)
//	//random starting index
//	_blood.image_index = random(5);
//	//random lifetime 
//	_blood.lifetime = random(12)
//	_blood.image_speed = 1;
//	//determine if the blood is angled or sideways
//	if(_angled){	if sign(_facing) > 0 _blood.image_angle = random_range(20, 50) else _blood.image_angle = random_range( 120 , 150)}
//	else { if sign(_facing) > 0 _blood.image_angle = random_range(30, 0) else _blood.image_angle = random_range( 160 , 190)}
//	_blood.direction = _blood.image_angle;
//	//speed
//	_blood.speed = random_range(7, 10);
//}


function create_blood(_facing, _x, _y, _grv = 0.2) {
    var _blood = instance_create_layer(_x, _y, "Instances", obj_blood);
    
    // Set a random image index for variety (ensure your sprite has multiple subimages)
    _blood.image_index = 0; 
    
    // Set a random lifetime for the blood particle
    _blood.lifetime = random_range(10, 20); // You can adjust this range to your liking
    
    // Control the speed of the blood animation
    _blood.image_speed = 1;

    // Initialize blood velocity and angle
    var _speed = random_range(4, 6); // Initial speed of the blood particles
    var angle = _facing < 0? random_range( 150 , 180): random_range(30, 0)
    
    // Set the velocity of the blood particles
    _blood.hspeed = lengthdir_x(_speed, angle); // Horizontal speed
    _blood.vspeed = lengthdir_y(_speed, angle); // Vertical speed

    // Apply gravity to the blood particles
    _blood.gravity = 0.1; // Gravity value, tweak as needed for realistic effect
    _blood.gravity_direction = 270; // Downwards direction
	
	_blood.image_angle = direction;
}



function hit_pause(_time){
	
	var _t = current_time + _time
	while(current_time <= _t){}
	
}

function create_shake(){
	instance_create_layer(x, y, "Instances", obj_screenshake_large)
}
