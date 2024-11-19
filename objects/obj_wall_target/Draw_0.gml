draw_set_color(c_white)

draw_self()

draw_text(x, y, obj_game_state.fsm.get_current_state())

draw_text(x, y - 10, string(hit))


