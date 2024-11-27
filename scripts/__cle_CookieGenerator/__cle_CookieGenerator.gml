
/// Feather ignore all
/// @desc This class generates a light cookie that can be used with spot lights. The cookie can be generated from a sprite, surface or IES file. If not in use, free it from memory using .Destroy(). Getting the sprite with .GetSprite() will do that automatically for you.
/// @param {Real} width The size of the generated cookie image. Influence on quality.
function Crystal_Cookie(_width=256) constructor {
	// shader
	static __shader = __cle_shCookieMaker;
	static __u_polarProjectionEnable = shader_get_uniform(__shader, "u_polarProjectionEnable");
	static __u_polarProjectionRadial = shader_get_uniform(__shader, "u_polarProjectionRadial");
	static __u_intensity = shader_get_uniform(__shader, "u_intensity");
	static __u_power = shader_get_uniform(__shader, "u_power");
	static __u_distortionAmount = shader_get_uniform(__shader, "u_distortionAmount");
	static __u_distortionSmoothness = shader_get_uniform(__shader, "u_distortionSmoothness");
	static __u_distortionFrequency = shader_get_uniform(__shader, "u_distortionFrequency");
	static __u_outerSmoothness = shader_get_uniform(__shader, "u_outerSmoothness");
	static __u_innerSmoothness = shader_get_uniform(__shader, "u_innerSmoothness");
	static __u_innerScale = shader_get_uniform(__shader, "u_innerScale");
	static __u_outerScale = shader_get_uniform(__shader, "u_outerScale");
	// base
	__surface = -1;
	__sample = -1;
	__width = _width; // cookie size (width and height)
	__oldWidth = __width;
	// variables
	__intensity = 1;
	__power = 1.0;
	__distortionAmount = 0;
	__distortionSmoothness = 1;
	__distortionFrequency = 15;
	__outerSmoothness = 0;
	__innerSmoothness = 0;
	__innerScale = 0;
	__outerScale = 1;
	__polarProjectionEnable = true;
	__polarProjectionRadial = true;
	__smooth = true;
	
	#region Private Methods
	
	/// @desc Parse a IES file from a buffer.
	/// @ignore
	static __parseIES = function(_buffer) {
		// Copyright (C) 2024, Mozart Junior.
		// IESNA LM-63 (2019) - Works with 2002 and 1995 too.
		if (!buffer_exists(_buffer)) {
			__crystal_trace("IES error: Invalid buffer", 1);
			exit;
		}
		var _ies = {
			metadata : "",
			// photometric header
			numberOfLamps : 0, // total number of lamps in the luminaire.
			lumensPerLamp : 0,
			candelaMultiplier : 1,
			numVerticalAngles : 0,
			numHorizontalAngles : 0, // rows(lines) = for each candela group
			photometricType : 0,
			unitsType : 0,
			luminousDimensions : {
				width : 0,
				length : 0,
				height : 0,
			},
			ballastFactor : 0,
			fileGenerationType : 0,
			inputWatts : 0,
			// data
			verticalAngles : [],
			horizontalAngles : [],
			candelaValues : [],
			// 1 candela = 12.57 lumens
		};
		var _dataString = buffer_read(_buffer, buffer_text);
		var _dataStringLength = string_length(_dataString);
		var _linesArray = string_split(_dataString, "\n");
		var _linesAmount = array_length(_linesArray);
		var _lineIndex = 0;
		
		// Parse metadata
		// TILT = <Spec>, INCLUDE or NONE (most common)
		var _line = _linesArray[0];
		while(true) {
			_line = _linesArray[_lineIndex];
			if (string_pos("TILT", _line) != 0) {
				// found
				break;
			} else {
				if (_lineIndex == _linesAmount-1) {
					__crystal_trace("IES: Invalid format", 1);
					return undefined;
				}
			}
			_ies.metadata += _line;
			_lineIndex++;
		}
		array_delete(_linesArray, 0, _lineIndex+1);
		
		// Read Photometry data
		// read in sequence like a buffer
		var _stringUnique = string_concat_ext(_linesArray);
		var _data = string_split_ext(_stringUnique, [" ", ",", "\r", "\t"], true);
		
		var _position = 0;
		// if (TILT == INCLUDE): (2019 version - WIP)
		// <Lamp to Luminaire Geometry>,
		// <Number of Tilt Angles>,
		// <Angles>,
		// <Multiplying Factors>
		_ies.numberOfLamps = real(_data[_position++]);
		_ies.lumensPerLamp = real(_data[_position++]);
		_ies.candelaMultiplier = real(_data[_position++]);
		_ies.numVerticalAngles = real(_data[_position++]);
		_ies.numHorizontalAngles = real(_data[_position++]);
		_ies.photometricType = real(_data[_position++]);
		_ies.unitsType = real(_data[_position++]);
		_ies.luminousDimensions.width = real(_data[_position++]);
		_ies.luminousDimensions.length = real(_data[_position++]);
		_ies.luminousDimensions.height = real(_data[_position++]);
		_ies.ballastFactor = real(_data[_position++]);
		_ies.fileGenerationType = real(_data[_position++]);
		_ies.inputWatts = real(_data[_position++]);
		
		// get vertical angles
		for (var i = 0; i < _ies.numVerticalAngles; ++i) {
			_ies.verticalAngles[i] = _data[_position++];
		}
		
		// get horizontal angles
		for (var i = 0; i < _ies.numHorizontalAngles; ++i) {
			_ies.horizontalAngles[i] = _data[_position++];
		}
		
		// get candela values (separated)
		for (var h = 0; h < _ies.numHorizontalAngles; h++) {
			var _candelaRow = [];
			for (var v = 0; v < _ies.numVerticalAngles; v++) {
				array_push(_candelaRow, _data[_position++]);
			}
			array_push(_ies.candelaValues, _candelaRow);
		}
		// single array
		//for (var i = 0; i < _ies.numVerticalAngles * _ies.numHorizontalAngles; i++) {
		//	array_push(_ies.candelaValues, _data[_position++]);
		//}
		
		return _ies;
	}
	
	/// @desc Generate surface from IES data.
	/// @ignore
	static __IESDataToSurface = function(_iesData, _width=256) {
		var _numVerticalAngles = _iesData.numVerticalAngles;
		var _numHorizontalAngles = _iesData.numHorizontalAngles;
		var _candelaValues = _iesData.candelaValues;
	
		// find maximum candela value
		var _maxCandela = 0;
		for (var h = 0; h < _numHorizontalAngles; h++) {
			for (var v = 0; v < _numVerticalAngles; v++) {
				var value = real(_candelaValues[h][v]);
				if (value > _maxCandela) _maxCandela = value;
			}
		}
	
		// create surface and draw LUT
		var _amount = _numHorizontalAngles * _numVerticalAngles;
		var _surfaceWidth = _width;
		var _surface = surface_create(_surfaceWidth, 1); //max(_surfaceWidth, _amount)
		surface_set_target(_surface);
			draw_clear_alpha(c_black, 1);
			var
			_index = 0,
			_reciprocal = 0,
			_candelaIndex = 0, // to track position between candela values
			_prevValue, _nextValue, _interpolatedValue;
		
			// write points using interpolation to fit the surface size
			for (var i = 0; i < _surfaceWidth; i++) {
				_reciprocal = i / _surfaceWidth;
				// get index based on reciprocal to find which points to interpolate
				_index = _reciprocal * (_amount - 1);
				_candelaIndex = floor(_index);
				var h = _candelaIndex div _numVerticalAngles;
				var v = _candelaIndex mod _numVerticalAngles;
			
				// get the current candela value and the next one for interpolation
				_prevValue = real(_candelaValues[h][v]) / _maxCandela;        
				if (_candelaIndex + 1 < _amount) {
					var _Hnext = (_candelaIndex + 1) div _numVerticalAngles;
					var _Vnext = (_candelaIndex + 1) mod _numVerticalAngles;
					_nextValue = real(_candelaValues[_Hnext][_Vnext]) / _maxCandela;
				} else {
					_nextValue = _prevValue; // no next value, repeat the current one
				}
			
				// draw pixel
				_interpolatedValue = lerp(_prevValue, _nextValue, _index-_candelaIndex);
				var _value = clamp(_interpolatedValue*255, 0, 255);
				draw_set_color(make_color_rgb(_value, _value, _value));
				draw_point(i, 0);
			}
		surface_reset_target();
		return _surface;
	}
	
	/// @desc Renderize sample sprite inside surface. When using UI, should be called there too (for realtime preview).
	/// @ignore
	static __renderize = function() {
		var _width = __width,
			_height = __width;
		if (__oldWidth != _width) {
			__oldWidth = _width;
			surface_free(__surface);
		}
		if (!surface_exists(__surface)) {
			__surface = surface_create(_width, _height);
		}
		surface_set_target(__surface);
			draw_clear(c_black);
			if (__sample != -1) {
				var _oldTexFilter = gpu_get_tex_filter();
				gpu_set_tex_filter(__smooth);
				shader_set(__shader);
				shader_set_uniform_f(__u_polarProjectionEnable, __polarProjectionEnable);
				shader_set_uniform_f(__u_polarProjectionRadial, __polarProjectionRadial);
				shader_set_uniform_f(__u_intensity, __intensity);
				shader_set_uniform_f(__u_power, __power);
				shader_set_uniform_f(__u_distortionAmount, __distortionAmount);
				shader_set_uniform_f(__u_distortionSmoothness, __distortionSmoothness);
				shader_set_uniform_f(__u_distortionFrequency, __distortionFrequency);
				shader_set_uniform_f(__u_outerSmoothness, __outerSmoothness);
				shader_set_uniform_f(__u_innerSmoothness, __innerSmoothness);
				shader_set_uniform_f(__u_innerScale, __innerScale);
				shader_set_uniform_f(__u_outerScale, __outerScale);
				if (sprite_exists(__sample)) {
					draw_sprite_stretched(__sample, 0, 0, 0, _width, _height);
				} else
				if (surface_exists(__sample)) {
					draw_surface_stretched(__sample, 0, 0, _width, _height);
				}
				shader_reset();
				gpu_set_tex_filter(_oldTexFilter);
			}
		surface_reset_target();
	}
	
	#endregion
	
	#region Public Methods
	
	/// @desc Delete cookie from memory. The generated sprite with .GetSprite() will NOT be deleted! Only the internal surface.
	static Destroy = function() {
		if (surface_exists(__surface)) surface_free(__surface);
	}
	
	/// @desc Load a sample from an .IES file loaded from a buffer.
	/// @method FromIES(buffer, deleteBuffer)
	/// @param {Id.Buffer} buffer The buffer to load data from. You can use buffer_load() or buffer_load_async() - see GM manual.
	/// @param {Bool} deleteBuffer If true (default), it will delete the buffer immediately after loading the data.
	static FromIES = function(_buffer, _deleteBuffer=true) {
		try {
			var _surf = __IESDataToSurface(__parseIES(_buffer), __width);
			__sample = sprite_create_from_surface(_surf, 0, 0, surface_get_width(_surf), surface_get_height(_surf), false, false, 0, 0);
			surface_free(_surf);
			__renderize();
			if (_deleteBuffer) buffer_delete(_buffer);
		} catch(_error) {
			__crystal_trace($"IES parse error: {_error.message}");
		}
		return self;
	}
	
	/// @desc Load a sample from a surface.
	/// @method FromSurface(sprite)
	/// @param {Id.Surface} surface The surface to generate cookie from.
	static FromSurface = function(_surface) {
		__sample = _surface;
		__renderize();
		return self;
	}
	
	/// @desc Load a sample from a sprite.
	/// @method FromSprite(sprite)
	/// @param {Asset.GMSprite} sprite The sprite to generate cookie from.
	static FromSprite = function(_sprite) {
		__sample = _sprite;
		__renderize();
		return self;
	}
	
	/// @desc Create a permanent sprite from the generated cookie surface. This will also destroy the cookie data from memory.
	/// @method GetSprite()
	static GetSprite = function() {
		var _sprite = sprite_create_from_surface(__surface, 0, 0, surface_get_width(__surface), surface_get_height(__surface), false, false, 0, 0);
		Destroy();
		return _sprite;
	}
	
	/// @desc Returns the realtime cookie texture.
	/// @method GetSurface()
	static GetSurface = function() {
		return __surface;
	}
	#endregion
}
