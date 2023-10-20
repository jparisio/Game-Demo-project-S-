magnitude = 30;

var _shake = fx_create("_filter_screenshake");
fx_set_parameter(_shake,"g_Magnitude", magnitude);
fx_set_parameter(_shake,"g_ShakeSpeed", 6);
layer_set_fx("Instances", _shake);

alarm[0] = 5;


