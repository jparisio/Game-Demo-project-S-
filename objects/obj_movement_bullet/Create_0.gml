event_inherited();

create_shells = true;

lifespan = 8;

move_frames = 9;

create_shake();
audio_play_sound(snd_shotgun_bullet, 7, 0);

dust_ring = instance_create_layer(x, y, "Instances", obj_dust_ring);
dust_ring.image_angle = point_direction(mouse_x, mouse_y, obj_player.x, obj_player.y - 22) - 90;