//state machine step event
fsm.step();

//move slowly back to idle
hsp = lerp(hsp, 0, .15);
if abs(hsp) <= 0.01 hsp = 0;

//decrement flash alpha to original state if hitflash is on
if flash_alpha >= 0 flash_alpha -= 0.05;

//show_debug_message(hsp)
//show_debug_message(sign(target_point - x))
