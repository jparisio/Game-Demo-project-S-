function WaitAction(_duration) : CutsceneAction("wait") constructor
{
    //action_parent = new CutsceneAction("wait");
    duration = _duration;

    // Define the method as a variable
    Execute = function(_controller) {
        if (_controller.cutscene_timer < duration) {
            _controller.cutscene_timer += 1;
        } else {
            _controller.cutscene_timer = 0;
            _controller.NextAction();
        }
    }
}
