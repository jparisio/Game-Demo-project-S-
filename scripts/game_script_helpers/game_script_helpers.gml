function scr_text(_text){
	game_dialogue[index] = _text
	index++;
}

function game_script(_text_id){
	
	switch(_text_id){
		
		case "test":
			scr_text("hello")
			scr_text("helloooooo")
			scr_text("is anyone gonna [shake_screen][c_red]ANSWER[c_red]")
			scr_text("this, is a [wave]test[/wave] and im [rainbow]trying[/rainbow], to see how this works[ended]") 
		break;
		
		case "test2":
			scr_text("oh shit")
			scr_text("sprayed blood all over there");
			scr_text("[switch, obj_shop][shake_screen]HEY")
			scr_text("you got [c_red][shake]blood[/shake] [c_white]all over my [shake_screen]SHOP")
			scr_text("YOU GOTTA CLEAN THIS. [shake_screen]NOW")
			scr_text("[switch, obj_player]my bad, ill get on that sir...")
			scr_text("or maam...")
			scr_text("[shake]sorry[/shake][ended]");
		break;
		
		case "katana":
			scr_text("This is a demo")
			scr_text("testing out the dialogue system");
			scr_text("Long strings seem to work and everything looks fluid")
			scr_text("heres the finish[ended]");
		break;
		
	}
	
}