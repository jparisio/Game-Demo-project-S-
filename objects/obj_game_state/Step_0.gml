fsm.step();

if input_check("pause") and fsm.get_current_state() != "main menu"{
	fsm.change("main menu")
	room_goto(Room0);
}

show_debug_message(instance_number(obj_light_manager))

