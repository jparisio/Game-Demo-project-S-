//ghost sprite switch
global.ghost = true;

global.game_speed = 1;

//bosses
global.boss_fight = false;


//cutscenes 
global.cutscene_ended = false;

//game state
global.current_fsm = 0;

//cam properties
global.cam_width = 640;
global.cam_height = 360;
global.x_offset = 0.45;
//global.y_offset = 0.8;
global.y_offset = 0.7;

global.clamp_cam_min = 260;
global.clamp_cam_max = 270;
global.cam_follow_y = false;


//app surface
global.app_ratio_y = 1;
global.app_ratio_x = 1;

//room restart state capture
global.initial_player_state = [];
global.initial_enemy_states = [];
global.initial_window_states = [];
global.initial_item_states = [];


//blood
global.blood_colour = #fe00a7;
//tests
//#cb0c1f - #d146fb - #4038ff

//screen shake
global.screen_shake_magnitude = 30;