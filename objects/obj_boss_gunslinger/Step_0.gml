fsm.step();

if flash_alpha >= 0 flash_alpha -= 0.05

if (fsm.get_current_state() != "injured" and fsm.get_current_state() != "teleport")  facing = sign(obj_player.x - x);
