if creator == obj_player{
	other.stunned = true;
	other.hsp -= 4 * move_dir;
	instance_destroy(self);
}





