
// Feather ignore all

/// @desc Creates a Time Cycle system. It is responsible for controlling the ambient light and the intensity of the lights. It also has an internal clock, which can be adjusted. The clock supports hours, minutes and seconds.
/// @param {Array} lutSpritesArray Array containing the LUT sprites. The order is from 00:00 until 23:59. You can add as many as you want.
/// @param {Bool} clockIsEnabled Sets whether the clock is counting or not. The clock is just the time counter.
/// @param {Real} clockSpeed Scalar speed of counting time. Usage (without quotes): "1/60": 24 hours time, "1": 24 minutes time, "60": 24 seconds time.
/// @param {Bool} isCycling If true, a LUT surface will be generated and sent to the Crystal_Renderer (from .Apply()), and the ambient light and lights intensity will be adjusted according to the curve (overriding).
/// @param {Real} lutType The LUT type to be used.  0: Strip, 1: Grid, 2: Hald Grid (Cube).
/// @param {Real} lutHorizontalSquares Horizontal LUT squares. Example: 16 (Strip), 8 (Grid), 8 (Hald Grid).
/// @param {Asset.GMAnimcurve} animCurve Animation curve that will be used to manipulate the LUT blending time and Lights Intensity. Ambient curve must range from 0 to 1, and lights should range from 0 to +;
/// @param {Real} ambientChannel Ambient animation curve channel, used to define cycle progress between LUTs. Use 0 or the channel name.
/// @param {Real} lightChannel Light animation curve channel, used to define lights intensity progress. Use 1 or the channel name.
/// @returns {struct}
function Crystal_TimeCycle(_lutSpritesArray, _clockIsEnabled, _clockSpeed, _isCycling, _lutType=1, _lutHorizontalSquares=8, _animCurve=__cle_acTimeCycle, _ambientChannel=0, _lightChannel=1) constructor {
	// main
	__lutSprites = _lutSpritesArray;
	__clockSpd = _clockSpeed;
	__clockIsEnabled = _clockIsEnabled;
	__isCycling = _isCycling;
	__lutType = _lutType;
	__lutHorizontalSquares = _lutHorizontalSquares;
	__curveChannelAmbient = animcurve_get_channel(_animCurve, _ambientChannel);
	__curveChannelLight = animcurve_get_channel(_animCurve, _lightChannel);
	__timeSource = undefined;
	__applied = false;
	__surface = -1;
	__surfaceTexture = -1;
	__progressAmbient = 0;
	__progressLight = 0;
	__timeNormalized = 0; // 0 - 1
	__sunAngle = 0;
	__deltaTime = 1;
	__hour = 0;
	__minute = 0;
	__second = 0;
	__day = 0;
	__renderer = undefined;
	
	#region Private Methods
	
	/// @ignore
	__step = function() {
		// Time clock
		if (__clockIsEnabled) {
			__second += __clockSpd * __deltaTime;
			if (__second >= 60) {
				__minute += (__second / 60); // 1 or..
				__second = __second % 60; // remaining
			}
			if (__minute >= 60) {
				__hour += (__minute / 60); // 1 or..
				__minute = __minute % 60;
			}
			if (__hour >= 24) {
				__day += round(__hour / 24); // 1 or..
				__hour = 0;
				__minute = 0;
				__second = 0;
			}
		}
		
		// Ambient Light LUT + Lights Intensity
		if (__isCycling) {
			// set progress from internal timer
			SetTimeNormalized(-1);
			
			// update lighting parameters
			__progressAmbient = animcurve_channel_evaluate(__curveChannelAmbient, __timeNormalized);
			__progressLight = animcurve_channel_evaluate(__curveChannelLight, __timeNormalized);
			
			// create lut surface
			if (!surface_exists(__surface)) {
				var _width, _height;
				if (__lutType == 0) {
					_width = __lutHorizontalSquares * __lutHorizontalSquares;
					_height = __lutHorizontalSquares;
				} else {
					_width = __lutHorizontalSquares * __lutHorizontalSquares * __lutHorizontalSquares;
					_height = _width;
				}
				__surface = surface_create(_width, _height);
				__surfaceTexture = surface_get_texture(__surface);
			}
			
			// renderize lut
			var _len = array_length(__lutSprites); // 4
			if (_len <= 0) exit;
			//var _reciprocal = 1 / (_len); // 0.25
			//var _recCurrent = __progressAmbient % _reciprocal; // 0 - 0.25
			//var _alpha = _recCurrent/_reciprocal; // 0 - 1
			surface_set_target(__surface);
				draw_clear(c_white);
				var _pos = max(0, min(1, __progressAmbient)) * _len;
				var _ind = min(floor(_pos), _len-1);
				_pos -= _ind; // frac
				var _cSpr = __lutSprites[_ind];
				var _nSpr = __lutSprites[min(_len-1, _ind+1)];
				gpu_push_state();
					gpu_set_zwriteenable(false);
					gpu_set_ztestenable(false);
					gpu_set_alphatestenable(false);
					gpu_set_blendenable(true);
					gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_one);
					draw_sprite_ext(_cSpr, 0, 0, 0, 1, 1, 0, c_white, 1);
					draw_sprite_ext(_nSpr, 0, 0, 0, 1, 1, 0, c_white, _pos);
				gpu_pop_state();
			surface_reset_target();
			
			// update renderer's lights paramaters (if available)
			if (__renderer != -1) SendParameters(__renderer);
		} else {
			// if not rendering and surface existed before, clean it and reset renderer's LUT
			if (surface_exists(__surface)) {
				surface_free(__surface);
				__surfaceTexture = -1;
				if (__renderer != -1) __renderer.SetAmbientLUT(-1);
			}
		}
    }
	
	#endregion
	
    #region Public Methods
	
	/// @desc Destroy time cycle (free from memory and stop execution). It is possible to call .Apply() again after calling this function.
    /// @method Destroy()
    static Destroy = function() {
		if (surface_exists(__surface)) surface_free(__surface);
		if (__timeSource != undefined) {
			time_source_destroy(__timeSource);
		}
		__applied = false;
		__crystal_trace("Time Cycle system destroyed.", 2);
    }
	
	/// @desc Apply Day Night Cycle to a renderer. Internally, this function will execute a Time Source to run the logic. This time source is responsible for running the clock and generating the LUT.
	/// 
	/// Leave as -1 if you don't want to send data to the renderer automatically (useful if you want to reuse the same Time Cycle system in more than one Crystal_Renderer()).
	/// Then you will use .SendParameters() in Step Event to send the same Time Cycle instance to more than one renderer. This does NOT apply if you are only using a single Crystal_Renderer().
	/// @method Apply(renderer)
	/// @param {Struct.Crystal_Renderer,Real} renderer The renderer to add the TimeCycle for rendering. If not specified, adds to the last created renderer (or set with crystal_set_renderer()).
	static Apply = function(_renderer=global.__CrystalCurrentRenderer) {
		// check
		if (__applied) return;
		if (_renderer == undefined) {
			__crystal_trace("TimeCycle not created, renderer not found. (creation order?)", 1);
			exit;
		}
		__renderer = _renderer;
		// initialize function execution for this layer renderer
		if (__timeSource == undefined) {
			__timeSource = time_source_create(time_source_game, 1, time_source_units_frames, __step, [], -1);
			time_source_start(__timeSource);
		}
		__applied = true;
	}
	
	/// @desc Sends ambient light and light intensity parameters to a renderer. Can be used in more than one renderer (for split-screen games, for example), using the same Crystal_TimeCycle(). This function should only be used if you have set "renderer" to -1 in .Apply().
	/// @method SendParameters(_renderer)
	/// @param {Struct.Crystal_Renderer} renderer The renderer to send info to.
	static SendParameters = function(_renderer) {
		if (_renderer != undefined) {
			_renderer.__lightsIntensity = __progressLight;
			_renderer.SetAmbientLUT(__surfaceTexture, __lutType, __lutHorizontalSquares);
		}
	}
	
	/// @desc Sets whether the clock is counting or not. The clock is just the time counter.
	/// @method SetClockEnable(enabled)
	/// @param {Bool} active If true, the clock will run. Use -1 to toggle.
	static SetClockEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__clockIsEnabled = !__clockIsEnabled;
		} else {
			__clockIsEnabled = _enabled;
		}
	}
	
	/// @desc If true, a LUT surface will be generated and sent to the Crystal_Renderer (from .Apply()), and the intensity of the lights will be adjusted according to the curve (overriding).
	/// @method SetCyclingEnable(enabled)
	/// @param {Bool} active If true, the clock will run.
	static SetCyclingEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isCycling = !__isCycling;
		} else {
			__isCycling = _enabled;
		}
	}
	
	/// @desc Defines the array with LUT sprites, used to interpolate colors.
	/// @method SetLUTSprites(lutSpritesArray)
	/// @param {Array} lutSpritesArray The array with LUT sprites.
	static SetLUTSprites = function(_lutSpritesArray) {
		__lutSprites = _lutSpritesArray;
	}
	
    /// @desc Sets the Day & Night cycle time. It is possible to skip parameters, for example: change only the minutes: .SetTime(, 30); This will leave the rest untouched.
    /// @method SetTime(hours, minutes, seconds, days)
    /// @param {Real} hours Hours amount. 0 - 24.
    /// @param {Real} minutes Minutes amount. 0 - 60.
    /// @param {Real} seconds Seconds amount. 0 - 60.
    /// @returns {undefined}
    static SetTime = function(_hours=undefined, _minutes=undefined, _seconds=undefined) {
		__hour = _hours ?? __hour;
		__minute = _minutes ?? __minute;
		__second = _seconds ?? __second;
    }
	
	/// @desc Sets the Day & Night cycle time, but using a normalized value (from 0 to 1). Useful if you want to define the progress yourself, like for time seasons for example.
	/// Using this function causes the internal timer to be ignored.
	/// @method SetTimeNormalized(time)
	/// @param {Real} time The normalized time (from 0 to 1).
	static SetTimeNormalized = function(_time) {
		if (_time < 0) {
			__timeNormalized = (3600 * __hour + 60 * __minute + __second) / 86400;
		} else {
			__timeNormalized = _time;
		}
		__sunAngle = (-__timeNormalized * 360);
	}
	
	/// @desc Sets the delta time variable to be used in the clock (optional).
	/// @method SetDeltaTime(deltaTime)
	/// @param {Real} deltaTime The delta time. 1 is the default delta time.
	static SetDeltaTime = function(_deltaTime=1) {
		__deltaTime = _deltaTime;
	}
    
    /// @desc Set clock speed.
    /// @method SetClockSpeed(clockSpeed)
    /// @param {Real} clockSpeed Scalar speed of counting time. Usage (without quotes): "1/60": 24 hours time, "1": 24 minutes time, "60": 24 seconds time.
    static SetClockSpeed = function(_clockSpeed) {
		__clockSpd = _clockSpeed;
    }
	
	/// @desc Returns the sun angle (from 0 to 360 degrees) with respect to time.
	/// @method GetSunAngle()
	static GetSunAngle = function() {
		return __sunAngle;
	}
	
    /// @desc Returns the formatted time of day and night cycle.
    /// @method GetTime()
    /// @returns {string} Time.
    static GetTime = function() {
		return __crystal_string_zeros(__hour, 2) + ":" + __crystal_string_zeros(__minute, 2) + ":" + __crystal_string_zeros(__second, 2);
    }
	
    /// @desc Returns time normalized to a value from 0 to 1.
    /// @method GetTimeNormalized()
    static GetTimeNormalized = function() {
		return __timeNormalized;
    }
	
    /// @desc Returns the hours of the day and night cycle.
    /// @method GetHours()
    static GetHours = function() {
		return __hour;
    }
	
    /// @desc Returns the minutes of the day and night cycle.
    /// @method GetMinutes()
    static GetMinutes = function() {
		return __minute;
    }
	
    /// @desc Returns the second of the day and night cycle.
    /// @method GetSeconds()
    static GetSeconds = function() {
		return __second;
    }
	
    /// @desc Returns the days of the day and night cycle.
    /// @method GetDays()
    static GetDays = function() {
		return __day;
    }
	
    /// @desc Get clock speed
    /// @method GetClockSpeed()
    static GetClockSpeed = function() {
		return __clockSpd;
    }
	
    #endregion
}
