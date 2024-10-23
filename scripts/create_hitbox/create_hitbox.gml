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