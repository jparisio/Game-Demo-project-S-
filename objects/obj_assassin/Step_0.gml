//state machine step event
fsm.step();

//decrement flash alpha to original state if hitflash is on
if flash_alpha >= 0 flash_alpha -= 0.05;

//destroy if outside of the room
var _state = fsm.get_current_state()
if !on_ground(self) and _state!= "stunned" and _state != "dead" fsm.change("stunned");