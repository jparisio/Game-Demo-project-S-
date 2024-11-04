//update the sprites
var _updated_arr = obj_player.gun.get_bullets();
for (var i = 0; i < array_length(bullet_ui_arr); i++) {
	//var _temp_bullet_ui_arr = array_reverse(bullet_ui_arr);
	var _curr_bullet = _updated_arr[i];
	if (_curr_bullet != -1) bullet_ui_arr[i].bullet_sprite = _curr_bullet.sprite;
}






