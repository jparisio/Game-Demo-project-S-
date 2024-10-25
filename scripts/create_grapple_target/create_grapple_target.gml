/**
 * Creates a grapple target at a specific position.
 * @param {instance} _follow - The instance to follow.
 * @param {number} _x - The x-coordinate.
 * @param {number} _y - The y-coordinate.
 * @param {number} _offset - The grapple target's vertical offset on the instance
 * @param {number} _radius - The grapple target's radius.
 */

function create_grapple_target(_follow, _x, _y, _offset, _radius = 140, grapple_scale = 1, _grapple_type = "grapple enemy"){
	var grap_point = instance_create_layer(_x, _y, "Instances", obj_grapple_point);
	grap_point.grapple_type = _grapple_type;
	grap_point.follow = _follow;
	grap_point.offset = _offset;
	grap_point.radius = _radius;
	grap_point.image_xscale = grapple_scale;
	grap_point.image_yscale = grapple_scale;
	grap_point.visible = false;
	return grap_point;
}