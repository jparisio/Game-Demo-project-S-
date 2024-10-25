var _inst = instance_place(x, y, obj_hitbox);

if (_inst != noone && _inst.creator == "player") {
    hspeed = 4;
    vspeed = -4;
    gravity = 0.15;
	gravity_direction = 270;
}





