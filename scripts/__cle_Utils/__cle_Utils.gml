
/// @Feather ignore all

// Emission
/// @desc Defines the emission shader.
/// @param {Real} intensity The emission intensity.
function mat_emission_begin(_intensity=1) {
	static __u_emission = shader_get_uniform(__cle_shEmission, "u_emission");
	shader_set(__cle_shEmission);
	shader_set_uniform_f(__u_emission, _intensity);
}

/// @desc Defines the emission intensity. Must be used after mat_emission_begin().
/// @param {Real} intensity The emission intensity.
function mat_emission_set_intensity(_intensity=1) {
	static __u_emission = shader_get_uniform(__cle_shEmission, "u_emission");
	shader_set_uniform_f(__u_emission, _intensity);
}

/// @desc Ends the emission shader.
function mat_emission_end() {
	shader_reset();
}


// Normal
/// @desc Defines the normal shader.
/// @param {Real} angle The normal angle.
/// @param {Real} scaleX The normal x scale.
/// @param {Real} scaleY The normal y scale.
function mat_normal_begin(_angle, _scaleX, _scaleY) {
	static __u_normalAngle = shader_get_uniform(__cle_shNormal, "u_angle");
	static __u_normalScale = shader_get_uniform(__cle_shNormal, "u_scale");
	shader_set(__cle_shNormal);
	shader_set_uniform_f(__u_normalAngle, _angle);
	shader_set_uniform_f(__u_normalScale, _scaleX, _scaleY);
}

/// @desc Defines the normal angle. Must be used after mat_normal_begin().
/// @param {Real} angle The normal angle.
function mat_normal_set_angle(_angle) {
	static __u_normalAngle = shader_get_uniform(__cle_shNormal, "u_angle");
	shader_set_uniform_f(__u_normalAngle, _angle);
}

/// @desc Defines the normal scale. Must be used after mat_normal_begin().
/// @param {Real} scaleX The normal x scale.
/// @param {Real} scaleY The normal y scale.
function mat_normal_set_scale(_scaleX, _scaleY) {
	static __u_normalScale = shader_get_uniform(__cle_shNormal, "u_scale");
	shader_set_uniform_f(__u_normalScale, _scaleX, _scaleY);
}

/// @desc Ends the normal shader.
function mat_normal_end() {
	shader_reset();
}


// Dithering
/// @desc Since deferred rendering is notorious for issues with opacity, this should help in some cases where you need to have things with a lot of transparency and WITH depth buffer enabled. The shader discards fragments based on opacity, using dithering.
/// @param {Real} threshold The threshold to start dithering (0 - 1). Default is 0 (full alpha).
/// @param {Asset.GMSprite} bayerSprite The matrix sprite to be used for dithering.
/// @param {Real} bayerSize The bayer matrix sprite size.
function deferred_alpha_begin(_threshold=0, _bayerSprite=__cle_sprBayer8x8, _bayerSize=8) {
	static __u_bayerTexture = shader_get_sampler_index(__cle_shAlphaDithering, "u_bayerTexture");
	static __u_bayerUVs = shader_get_uniform(__cle_shAlphaDithering, "u_bayerUVs");
	static __u_bayerSize = shader_get_uniform(__cle_shAlphaDithering, "u_bayerSize");
	static __u_threshold = shader_get_uniform(__cle_shAlphaDithering, "u_threshold");
	shader_set(__cle_shAlphaDithering);
	gpu_push_state();
	texture_set_stage(__u_bayerTexture, sprite_get_texture(_bayerSprite, 0));
	gpu_set_tex_filter_ext(__u_bayerTexture, false);
	gpu_set_tex_repeat_ext(__u_bayerTexture, false);
	var _bayerUVs = sprite_get_uvs(_bayerSprite, 0);
	shader_set_uniform_f(__u_bayerUVs, _bayerUVs[0], _bayerUVs[1], _bayerUVs[2], _bayerUVs[3]);
	shader_set_uniform_f(__u_bayerSize, _bayerSize);
	shader_set_uniform_f(__u_threshold, _threshold);
}

/// @desc Ends the deferred alpha shader.
function deffered_alpha_end() {
	shader_reset();
	gpu_pop_state();
}


// ==================================================

#region Internal

/// @func __crystal_trace(text)
/// @param {String} text
/// @ignore
function __crystal_trace(_text, _level=1) {
	gml_pragma("forceinline");
	if (_level <= CLE_CFG_TRACE_LEVEL) show_debug_message($"# CRYSTAL >> {_text}");
}

/// @ignore
function __crystal_exception(_condition, _text) {
	gml_pragma("forceinline");
	if (CLE_CFG_ERROR_CHECKING_ENABLE && _condition) {
		// the loop below doesn't always run...
		var _separator = string_repeat("-", 92);
		show_error($"{_separator}\nCrystal Lighting Engine >> {instanceof(self)}\n{_text}\n\n\n{_separator}\n\n", true);
	}
}

/// @ignore
function __crystal_get_color_rgb(color) {
	gml_pragma("forceinline");
	return [color_get_red(color)/255, color_get_green(color)/255, color_get_blue(color)/255];
}

/// @ignore
function __crystal_wrap(_val, _min, _max) {
	var _mod = (_val - _min) % (_max - _min);
	return (_mod < 0) ? _mod + _max : _mod + _min;
}

/// @ignore
function __crystal_string_zeros(str, zero_amount) {
	return string_replace_all(string_format(str, zero_amount, 0), " ", "0");
}

/// @desc Returns surface format size (in bytes).
/// @param {Id.Surface} surface The surface to get format size.
/// @ignore
function __crystal_surface_format_get_size(_surface) {
	var _format = surface_get_format(_surface);
	switch(_format) {
		// 4 channels: R G B A
		case surface_rgba8unorm: return 4; break; // 8 bits (1 byte) per channel | 4 bytes (1+1+1+1)
		case surface_rgba16float: return 8; break; // 16 bits (2 bytes) per channel | 8 bytes (2+2+2+2)
		case surface_rgba32float: return 16; break; // 32 bits (4 bytes) per channel | 16 bytes (4+4+4+4)
	}
}

#endregion

#region Unused - Unfinished
/*
// Automatic vertices generation functions
// Provided by "Mead" ~ thank you
function crystal_meshes_generate_from_sprite(_sprite, _precision=1, _minAlpha=230, _angleDiff=35, _stepDist=5) {
	static _tau = (2 * pi);
	var _count = sprite_get_number(_sprite),
		_outlines = array_create(_count),
		_originX = sprite_get_xoffset(_sprite),
		_originY = sprite_get_yoffset(_sprite),
		_width = sprite_get_width(_sprite),
		_height = sprite_get_height( _sprite),
		_surface = surface_create(_width, _height),
		_buffer = buffer_create(((_width * _height) << 2), buffer_fast, 1),
		_prec = lerp(_tau, _tau/1000, _precision);
	// Iterate through all sub-images of the sprite
	for(var i = 0; i < _count; i++) {
		// convert current sub-image to buffer
		surface_set_target(_surface);
			draw_clear_alpha(c_black, 0);
			draw_sprite(_sprite, i, _originX, _originY);
		surface_reset_target();
		buffer_get_surface(_buffer, _surface, 0);
		
		// new array of points
		var _points = [], _rx, _ry, _bufferX, _bufferY;
		
		// raycasts
		for(var _theta = 0; _theta < _tau; _theta += _prec) {
			var _cosT = cos(_theta),
			_sinT = -sin(_theta),
			_pointX = _cosT,
			_pointY = _sinT,
			_ray_length = 2;
			while(_ray_length) {
				_rx = _cosT * _ray_length;
				_ry = _sinT * _ray_length++;
				_bufferX = floor(_originX + _rx);
				_bufferY = floor(_originY + _ry);
				// Check in bounds
				if (_bufferX >= _width || _bufferX <= 0 || _bufferY >= _height || _bufferY <= 0) {
					_ray_length = -1;
				} else
				if (buffer_peek(_buffer, (_bufferX + _bufferY * _width << 2) + 3, buffer_u8) > _minAlpha) {
					_pointX = _rx;
					_pointY = _ry;
				}
			}
			array_push(_points, _pointX, _pointY);
		}
		_outlines[i] = crystal_meshes_prune_shadow_outline(_points, _angleDiff, _stepDist);
		//_outlines[i] = _points;
	}
	surface_free(_surface);
	buffer_delete(_buffer);
	return _outlines;
}

function crystal_meshes_prune_shadow_outline(_points, _angleDiff, _stepDist) {
	// Loops around the sprite outline removing points based on angle difference and distance
	// This can remove hundreds of redundant points without any noticeable difference in precision
	
	var len = array_length(_points),
		px = _points[len - 2],
		py = _points[len - 1],
		tx = _points[0],
		ty = _points[1],
		dir = point_direction(px, py, tx, ty),
		prunedPoints = [px, py],
		dist = 0, ndir = 0, nx = 0, ny = 0, p = 2;
	
	while (p < len) {
		nx = _points[p++];
		ny = _points[p++];
		
		dist = point_distance(px, py, nx, ny);
		ndir = point_direction(tx, ty, nx, ny);
		
		if (dist > _stepDist && abs(angle_difference(dir, ndir)) >= _angleDiff) {
			array_push(prunedPoints, tx, ty);
			px = tx;
			py = ty;
			tx = nx;
			ty = ny;
			dir = point_direction(px, py, tx, ty);
		} else {
			tx = nx;
			ty = ny;
		}
	}
	// If needing to debug and see the difference pruning made
	//show_debug_message("Total points: " + string(len >> 1) + " After pruning: " + string(array_length(prunedPoints) >> 1));
	return prunedPoints;
}
*/
#endregion
