var _bullets = obj_player.gun.get_bullets(); // Get bullets from the player's gun
var bullet_spacing = 32; // Space between bullets
var x_start = 50; // X starting position for drawing
var y_start = display_get_gui_height() - 50; // Y position at the bottom of the screen

for (var i = 0; i < array_length(_bullets); i++) {
    var bullet_state = _bullets[i];
    if (bullet_state == -1) {
        draw_sprite(spr_bullet_ui, 1, x_start + (i * bullet_spacing), y_start); // Draw with image_index 1
    } else {
        draw_sprite(spr_bullet_ui, 0, x_start + (i * bullet_spacing), y_start); // Draw with image_index 0
    }
}

