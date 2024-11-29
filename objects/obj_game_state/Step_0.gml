fsm.step();

if input_check("pause") and fsm.get_current_state() != "main menu"{
	fsm.change("main menu")
	room_goto(Room0);
}


