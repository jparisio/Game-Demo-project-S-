function character(_sprites_act1, _sprites_act2) {
    return {
        sprites_act1: _sprites_act1,
        sprites_act2: _sprites_act2,
		current_sprite: 0,
        
        setSprite: function(state) {
            var _sprites = global.ghost ? sprites_act2 : sprites_act1;

            switch (state) {
                case "idle": current_sprite = {sprite: _sprites.idle, state: "idle"}; break;
                case "run": current_sprite = {sprite: _sprites.run, state: "run"}; break;
                case "jump": current_sprite = {sprite: _sprites.jump, state: "jump"}; break;
				case "jstart": current_sprite = {sprite: _sprites.jump_start, state: "jstart"}; break;
				case "jfall": current_sprite = {sprite: _sprites.jump_fall, state: "jfall"}; break;
				case "jfalls": current_sprite = {sprite: _sprites.jump_fall_start, state: "jfalls"}; break;
                case "dash": current_sprite = {sprite: _sprites.dash, state: "dash"}; break;
                case "rtoi": current_sprite = {sprite: _sprites.run_to_idle, state: "rtoi"}; break;
                case "itor": current_sprite = {sprite: _sprites.idle_to_run, state: "itor"}; break;
				case "wslide": current_sprite = {sprite: _sprites.wall_slide, state: "wslide"}; break;
                default: current_sprite = {sprite: _sprites.idle, state: "idle"}; break;
            }
			return current_sprite.sprite;
        },
		
		getSpriteState: function() {
            return current_sprite.state;
        }
    };
}
