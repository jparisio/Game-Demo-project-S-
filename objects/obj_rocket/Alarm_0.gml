//this is the alarm that makes rocket explode after set time
sprite_index = spr_empty;
alarm[2] = 30;
instance_create_layer(x, y, "Instances", obj_explosion);