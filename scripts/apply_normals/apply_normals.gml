// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function apply_normals(material, sprite, facing){
	//normals
	material.x = x;
	material.y = y;
	material.normalSprite = sprite
	material.normalSpriteSubimg = image_index;
	material.xScale = facing;
	material.Apply();
}