function character(_sprites_act1, _sprites_act2) {
    return {
        sprites_act1: _sprites_act1,
        sprites_act2: _sprites_act2,
        
        getSprite: function(state) {
            var act_sprites = global.ghost ? sprites_act2 : sprites_act1;

            switch (state) {
                case "idle": return act_sprites.idle;
                case "run": return act_sprites.run;
                case "jump": return act_sprites.jump;
				case "dash": return act_sprites.dash;
				case "rtoi": return act_sprites.run_to_idle;
				case "itor": return act_sprites.idle_to_run;
                // Add other states here
                default: return act_sprites.idle; // Fallback sprite
            }
        }
    };
}
