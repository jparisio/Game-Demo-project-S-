if bounced {
	move_bounce_solid(false);
	bounced = false;
	speed = 16;
	alarm[0] = 3;
}

if destructable {
	instance_destroy();	
}

