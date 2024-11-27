
if (!relative) {
	x = 0;
	y = 0;
}
shadow = new Crystal_Shadow(id, CRYSTAL_SHADOW.STATIC, transformMode); 
shadow.shadowLength = shadowLength;
shadow.depth = depth;
shadow.AddMesh(new Crystal_ShadowMesh().FromPath(path));
shadow.Apply();
