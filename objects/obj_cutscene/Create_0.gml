cutscene = new CutsceneController();

// Define a series of cutscene actions
actions = [
    new MoveAction(obj_player, 575, 287, 4),
    new PlayAnim(obj_player, spr_steady),
	new DialogueAction(obj_player, "katana"),
	new PlayAnim(obj_player, spr_finisher),
	new PlayAnim(obj_player, spr_release),
	new ChangeSprite(obj_player, spr_idle),
	new DialogueAction(obj_player, "test"),
	new WaitAction(60)
];

start = false;



