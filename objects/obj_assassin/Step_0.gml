//state machine step event
fsm.step();
//collide_and_move();
//decrement timer to switch state after timer_maxseconds
timer_switch_state--;
timer_switch_state = clamp(timer_switch_state, -1, timer_max);

//timer for attack
timer_attack--
timer_attack = clamp(timer_attack, -1, timer_attack_max);

//move slowly back to idle
hsp = lerp(hsp, 0, .15);
if abs(hsp) <= 0.1 hsp = 0;

//decrement flash alpha to original state if hitflash is on
if flash_alpha >= 0 flash_alpha -= 0.05

//show_debug_message(move_dir)
//show_debug_message(hsp)
