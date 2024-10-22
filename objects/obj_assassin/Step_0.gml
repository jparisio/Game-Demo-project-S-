//state machine step event
fsm.step();

//decrement flash alpha to original state if hitflash is on
if flash_alpha >= 0 flash_alpha -= 0.05;

//destroy if outside of the room
// Destroy the object if it's outside the room bounds
if (x < 0 || x > room_width || y < 0 || y > room_height) {
    instance_destroy();
}