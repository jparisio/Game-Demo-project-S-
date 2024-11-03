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
			create_shake("small");
			audio_play_sound(snd_gunshot, 10, 0);
            var current_bullet = bullets[bullet_index];
            // Fire bullet and remove from array
            current_bullet.shoot(_x, _y, _direction);
			bullets[bullet_index] = -1;
            bullet_index++;
        } else {
			//out of ammo
			var _snd = choose(snd_empty_gun1, snd_empty_gun2, snd_empty_gun3);
			audio_play_sound(_snd, 10, 0);
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
    
    // Function to add a bullet back to the array (e.g., for pickups or reloads)
    add_bullet = function(_bullet_type) {
        if (array_length(bullets) < array_size) {
            array_push(bullets, _bullet_type);
        }
    };
}
