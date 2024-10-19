if (active) {
    // Ensure val is normalized between 0 and 1
    if (val <= 1) {
        // Increment the progress, controlling the speed of interpolation
        val += 1 / 20;  // Change 40 based on how quickly you want the interpolation
    }
    
    y = AnimcurveTween(y, move_to, acQuartIn, val);
}

if abs(move_to - y) <= 2 and active {
	active = false;
	shake = true;
	obj_player.chainsaw_fly = true;
}

if shake {
	create_shake("large");
	shake = false;
}



