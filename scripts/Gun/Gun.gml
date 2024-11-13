function Gun(_bullet, _max_ammo) constructor {
    bullets = [];                   // Array to store bullets
    array_size = _max_ammo;       // Size of the bullet array
    bullet = _bullet;
	bullet_index = 0;
	
    
    for (var i = 0; i < array_size; i++) {
        bullets[i] = bullet;
    }

    // Fire function that uses either the next_bullet nullet
    fire = function(_x, _y, _direction) {
        if (array_length(bullets) > bullet_index) {
            var current_bullet = bullets[bullet_index];
            // Fire bullet and remove from array
            current_bullet.shoot(_x, _y, _direction);
			bullets[bullet_index] = -1;
            bullet_index++;
        } else {
			//out of ammo
            show_debug_message("Out of bullets!");
        }
    };

    // Function to reset the bullet array back to full ammo
    reload = function() {
        bullets = [];
		bullet_index = 0;
        for (var i = 0; i < array_size; i++) {
            bullets[i] = bullet;
        }
    };

    // Function to return the current bullet array
    get_bullets = function() {
        return bullets;
    };
	
	get_index = function() {
        return bullet_index;
    };
	
	 is_empty = function() {
	    for (var i = 0; i < array_length(bullets); i++) {
	        if (bullets[i] != -1) {
	            return false;
	        }
	    }
		return true;
	}
	
	is_full = function(){
		 for (var i = 0; i < array_length(bullets); i++) {
	        if (bullets[i] == -1) {
	            return false;
	        }
	    }
		return true;
	}

	
	//set bullet defaulted to set the last bullet
	set_bullet = function(_bullet, _index = array_length(bullets) - 1) {
		if self.is_empty() bullet_index -= 1;
        bullets[_index] = _bullet;
    };
    
    // Function to add a bullet back to the array (e.g., for pickups or reloads)
    add_bullet = function(_bullet) {
		if(self.is_full()){
			self.set_bullet(_bullet, bullet_index);
			return 1;
		}
        if (bullet_index > 0 && bullets[bullet_index -1] == -1) {
            bullets[bullet_index -1] = _bullet;
			bullet_index -= 1;
			return 1;
        }
		//return 0 to indicate the bullet wasnt added
		return 0;
    };
}
