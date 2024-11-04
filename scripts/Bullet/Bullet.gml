function Bullet(__speed, _type) constructor {
    _speed = __speed; 
	type = _type;
	var _sprite = object_get_name(type); 
	_sprite = string_replace(_sprite, "obj_", "spr_"); // Replace "obj_" with "spr_"
	_sprite = string_concat(_sprite, "_ui");
	sprite = asset_get_index(_sprite)     //get the asset with the _sprite string name
	

	
    // Method to handle firing the bullet
    shoot = function(_x, _y, _direction) {
        var bullet_instance = instance_create_layer(_x, _y, "Instances", type);
        bullet_instance.speed = _speed;
        bullet_instance.direction = _direction;
    };

}