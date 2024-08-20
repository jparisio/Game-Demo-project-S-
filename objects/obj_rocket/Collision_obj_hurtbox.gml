//reduce hp
obj_player.hp -= self.damage;
//set invulnerbaility
obj_player.be_invulnerable = true;
//shake screen a lot
create_shake();
//hit pause
hit_pause(120)
//destroy so it doesnt infinately collide with the player
instance_destroy(obj_hurtbox);

instance_destroy();
