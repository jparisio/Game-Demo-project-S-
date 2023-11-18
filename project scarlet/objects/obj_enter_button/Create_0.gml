active = true
sin_wave = 0;
image_alpha = 0;


if (input_source_using(INPUT_GAMEPAD))
{
    
    sprite_index = spr_squ;
}
else
{

    sprite_index = spr_enter_button;
	image_xscale = 0.08;
	image_yscale = 0.08;
}