// time you run BktGlitch_activate(), which might take a few frames.
bktglitch_init()
application_surface_draw_enable(false); // disabling automatic redrawing of the application surface
alarm[0] = 180;