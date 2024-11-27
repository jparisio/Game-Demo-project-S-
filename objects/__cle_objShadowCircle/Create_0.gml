
shadow = new Crystal_Shadow(id, CRYSTAL_SHADOW.STATIC, transformMode); 
shadow.shadowLength = shadowLength;
shadow.depth = depth;
shadow.AddMesh(new Crystal_ShadowMesh().FromEllipse(sides, sprite_get_width(sprite_index), sprite_get_height(sprite_index), sprite_get_xoffset(sprite_index), sprite_get_yoffset(sprite_index)));
shadow.Apply();
