function Bullet(__speed) constructor {
    _speed = __speed; 
 
    // Method to handle firing the bullet
    shoot = function(_x, _y, _direction) {
        var bullet_instance = instance_create_layer(_x, _y, "Instances", obj_bullet);
        bullet_instance.speed = _speed;
        bullet_instance.direction = _direction;
    };

}
