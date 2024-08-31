// Create Event
x_start = 0;
x_end = global.cam_width + 50;
current_x = x_start;
animation_speed = 0.1; // Adjust this to control the speed of the lerp


target_x = 0;
target_y = 0;
next_room = 0;


finished = false;

audio_play_sound(snd_exit_screen, 10, 0, 1, 0.23);