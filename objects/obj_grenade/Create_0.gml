angle_to_player = point_direction(x, y, obj_player.x, obj_player.y);

// Initial vertical speed for the arc (adjust as needed)
y_velocity = -6; 
x_velocity = irandom_range(3, 6);
// Custom gravity value to pull the grenade downward
y_gravity = 0.2;

image_xscale = 2;

image_yscale = 2;

create_hitbox("boss", self, x, y, 1, spr_grenade_hitbox, 150, 10);