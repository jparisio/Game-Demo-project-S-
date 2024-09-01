//this is the alarm that makes rocket explode after set time
mask_index = spr_empty;
sprite_index = spr_empty;
dead = true;
alarm[2] = 30;
instance_create_layer(x, y, "Instances", obj_explosion);