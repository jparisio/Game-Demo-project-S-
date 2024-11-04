_bullets = obj_player.gun.get_bullets(); // Get bullets from the player's gun
_bullet_index = obj_player.gun.get_index();
bullet_spacing = 32; // Space between bullets
x_start = 50; // X starting position for drawing
y_start = display_get_gui_height() - 50; // Y position at the bottom of the screen
bullet_ui_arr = [];

//create the array of bullets
for (var i = array_length(_bullets) - 1; i >= 0; i--) {
    var _curr_bullet = _bullets[i];
		var _bull = instance_create_layer(x, y, "Instances", obj_bullet_ui);
		_bull.draw_x = x_start + (i * bullet_spacing);
		_bull.draw_y = y_start;
		_bull.index = i;
		_bull.bullet_sprite = _curr_bullet.sprite;
		array_push(bullet_ui_arr, _bull);
}