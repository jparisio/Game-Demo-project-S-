
shadow = new Crystal_Shadow(id, CRYSTAL_SHADOW.STATIC, transformMode);
shadow.shadowLength = shadowLength;
shadow.depth = depth;
shadow.AddMesh(new Crystal_ShadowMesh().FromSpriteRect(sprite_index));
shadow.Apply();