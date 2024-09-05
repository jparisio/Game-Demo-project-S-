/*
	By default, the shader adapts to the size of the application surface.
	You can pass your own resolution via the arguments of this function or by using
	the dedicated ones.
*/

// Activating the shader.
bktglitch_activate();
var line_speed = 0.196667
var line_shift = 0.012333
line_speed = lerp(line_speed, 0.4, 0.1);
line_shift = lerp(line_shift, 0.1, 0.1);
bktglitch_set_intensity(1.000000);
bktglitch_set_line_shift(0.012333);
bktglitch_set_line_speed(line_speed);
bktglitch_set_line_resolution(1.320000);
bktglitch_set_line_drift(0.166667);
bktglitch_set_line_vertical_shift(0.220000);
bktglitch_set_noise_level(0.500000);
bktglitch_set_jumbleness(0.200000);
bktglitch_set_jumble_speed(20.833333);
bktglitch_set_jumble_resolution(0.200000);
bktglitch_set_jumble_shift(0.300000);
bktglitch_set_channel_shift(0.004000);
bktglitch_set_channel_dispersion(0.002500);
bktglitch_set_shakiness(0.500000);
bktglitch_set_rng_seed(0.000000);
////// Alternatively:
bktglitch_config(0.012333, 0.196667, 1.320000, 0.166667, 0.220000, 0.200000, 20.833333, 0.200000, 0.300000, 0.500000, 0.004000, 0.002500, 0.500000, 1.000000, 0.000000);
// Drawing with shader active! 
// draw_surface(application_surface, 0, 0);
draw_surface(application_surface, 0, 0);

// Done with the shader (this is really just shader_reset)!
bktglitch_deactivate();



