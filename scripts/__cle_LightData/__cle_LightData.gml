
// Feather ignore all

/// @desc Class responsible for saving and loading all lights (dynamic and static), including their positions, depth and other parameters. Useful for editing lights in-game and then loading.
/// This only processes the lights. Shadows and anything else are not saved.
/// @param {Bool} destroyBeforeLoading If true, all lights will be destroyed before loading new lights. Default is false.
function Crystal_LightData(_destroyBeforeLoading=false) constructor {
	__fileFormat = ".lightdata"; // suggestion
	__version = 1;
	__versionMin = 1;
	__destroyAllLightsBeforeLoading = _destroyBeforeLoading;
	
	#region Private Methods
	
	/// @desc Generate JSON data from all lights.
	/// @ignore
	static __save = function(_description="Light Data from Crystal Lighting Engine") {
		// create json object
		var _json = {
			description : _description,
			version : __version,
			lights : [],
		};
		
		// make sure lights are not disabled
		instance_activate_object(__cle_objLightDynamic);
		instance_activate_object(__cle_objLightStatic);
		
		// get all lights data
		var _lightObjects = [__cle_objLightStatic, __cle_objLightDynamic];
		var o = 0, osize = array_length(_lightObjects),
			i = 0;
		// for each light object
		repeat(osize) {
			i = 0;
			with(_lightObjects[o]) {
				// save different things based on light type
				switch(type) {
					// Basic Light
					case CRYSTAL_LIGHT.BASIC:
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.BASIC,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							intensity : intensity,
							sprite : sprite_get_name(sprite_index),
							xScale : image_xscale,
							yScale : image_yscale,
							angle : image_angle,
							alpha : image_alpha,
							color : image_blend,
							frame : image_index,
							animSpeed : image_speed,
						});
						break;
					// Direct Light
					case CRYSTAL_LIGHT.DIRECT:
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.DIRECT,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							shaderType : shaderType,
							color : color,
							intensity : intensity,
							angle : angle,
							castShadows : castShadows,
							selfShadows : selfShadows,
							penetration : penetration,
							shadowPenumbra : shadowPenumbra,
							shadowUmbra : shadowUmbra,
							shadowScattering : shadowScattering,
							shadowDepthOffset : shadowDepthOffset,
							normalDistance : normalDistance,
							diffuse : diffuse,
							specular : specular,
							litType : litType,
							shadowLitType : shadowLitType,
						});
						break;
					// Point Light
					case CRYSTAL_LIGHT.POINT:
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.POINT,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							shaderType : shaderType,
							color : color,
							intensity : intensity,
							inner : inner,
							falloff : falloff,
							radius : radius,
							levels : levels,
							castShadows : castShadows,
							selfShadows : selfShadows,
							penetration : penetration,
							shadowPenumbra : shadowPenumbra,
							shadowUmbra : shadowUmbra,
							shadowScattering : shadowScattering,
							shadowDepthOffset : shadowDepthOffset,
							normalDistance : normalDistance,
							diffuse : diffuse,
							specular : specular,
							litType : litType,
							shadowLitType : shadowLitType
						});
						break;
					// Sprite Light
					case CRYSTAL_LIGHT.SPRITE:
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.SPRITE,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							sprite : sprite_get_name(sprite_index),
							intensity : intensity,
							xScale : image_xscale,
							yScale : image_yscale,
							angle : image_angle,
							alpha : image_alpha,
							color : image_blend,
							frame : image_index,
							animSpeed : image_speed,
							castShadows : castShadows,
							selfShadows : selfShadows,
							penetration : penetration,
							shadowPenumbra : shadowPenumbra,
							shadowUmbra : shadowUmbra,
							shadowScattering : shadowScattering,
							shadowDepthOffset : shadowDepthOffset,
							normalDistance : normalDistance,
							diffuse : diffuse,
							specular : specular,
							litType : litType,
							shadowLitType : shadowLitType
						});
						break;
					// Spot Light
					case CRYSTAL_LIGHT.SPOT:
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.SPOT,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							shaderType : shaderType,
							color : color,
							intensity : intensity,
							inner : inner,
							falloff : falloff,
							radius : radius,
							levels : levels,
							angle : angle,
							width : width,
							spotFOV : spotFOV,
							spotSmoothness : spotSmoothness,
							spotDistance : spotDistance,
							tilt : tilt,
							cookieTexture : cookieTexture, // hmm
							castShadows : castShadows,
							selfShadows : selfShadows,
							penetration : penetration,
							shadowPenumbra : shadowPenumbra,
							shadowUmbra : shadowUmbra,
							shadowScattering : shadowScattering,
							shadowDepthOffset : shadowDepthOffset,
							normalDistance : normalDistance,
							diffuse : diffuse,
							specular : specular,
							litType : litType,
							shadowLitType : shadowLitType
						});
						break;
					// Shape Light
					case CRYSTAL_LIGHT.SHAPE:
						var _pointsArray = [];
						// write path points to an array
						if (path != undefined) {
							var p = 0, psize = path_get_number(path);
							repeat(psize) {
								array_push(_pointsArray, path_get_point_x(path, p), path_get_point_y(path, p));
								++p;
							}
						}
						array_push(_json.lights, {
							name : object_get_name(object_index),
							type : CRYSTAL_LIGHT.SHAPE,
							x : x,
							y : y,
							enabled : enabled,
							depth : depth,
							pathPoints : _pointsArray,
							pathClosed : path_get_closed(path),
							cornerPrecision : cornerPrecision,
							shaderType : shaderType,
							color : color,
							colorOuter : colorOuter,
							intensity : intensity,
							inner : inner,
							falloff : falloff,
							radius : radius,
							levels : levels,
							angle : angle,
							xScale : xScale,
							yScale : yScale,
							castShadows : castShadows,
							selfShadows : selfShadows,
							penetration : penetration,
							shadowPenumbra : shadowPenumbra,
							shadowUmbra : shadowUmbra,
							shadowScattering : shadowScattering,
							shadowDepthOffset : shadowDepthOffset,
							normalDistance : normalDistance,
							diffuse : diffuse,
							specular : specular,
							litType : litType,
							shadowLitType : shadowLitType
						});
						break;
					default:
						var _objName = object_get_name(object_index);
						array_push(_json.lights, {
							name : _objName,
							type : -1,
						});
						__crystal_trace($"Unknown light object: {_objName}", 1);
						break;
				}
				i++;
			}
			o++;
		}
		
		return _json;
	}
	
	/// @ignore
	static __load = function(_json) {
		// (optional) destroy all lights before loading
		// not generally desired, as it may contain existing lights in the room
		if (__destroyAllLightsBeforeLoading) {
			// make sure lights are not disabled
			instance_activate_object(__cle_objLightDynamic);
			instance_activate_object(__cle_objLightStatic);
			// destroy existing lights
			instance_destroy(__cle_objLightStatic);
			instance_destroy(__cle_objLightDynamic);
		}
		
		// add all lights from json data
		var _lightsArray = _json.lights;
		var i = 0, isize = array_length(_lightsArray), _light = undefined;
		repeat(isize) {
			_light = _lightsArray[i];
			// instantiate object from asset name
			var _inst = instance_create_depth(_light.x, _light.y, _light.depth, asset_get_index(_light.name));
			// define properties based on type
			switch(_light.type) {
				// Basic Light
				case CRYSTAL_LIGHT.BASIC:
					_inst.sprite_index = asset_get_index(_light.sprite);
					_inst.enabled = _light.enabled;
					_inst.intensity = _light.intensity;
					_inst.image_xscale = _light.xScale;
					_inst.image_yscale = _light.yScale;
					_inst.image_angle = _light.angle;
					_inst.image_alpha = _light.alpha;
					_inst.image_blend = _light.color;
					_inst.image_index = _light.frame;
					_inst.image_speed = _light.animSpeed;
					break;
				// Direct Light
				case CRYSTAL_LIGHT.DIRECT:
					_inst.enabled = _light.enabled;
					_inst.shaderType = _light.shaderType;
					_inst.color = _light.color;
					_inst.intensity = _light.intensity;
					_inst.angle = _light.angle;
					_inst.castShadows = _light.castShadows;
					_inst.selfShadows = _light.selfShadows;
					_inst.penetration = _light.penetration;
					_inst.shadowPenumbra = _light.shadowPenumbra;
					_inst.shadowUmbra = _light.shadowUmbra;
					_inst.shadowScattering = _light.shadowScattering;
					_inst.shadowDepthOffset = _light.shadowDepthOffset;
					_inst.normalDistance = _light.normalDistance;
					_inst.diffuse = _light.diffuse;
					_inst.specular = _light.specular;
					_inst.litType = _light.litType;
					_inst.shadowLitType = _light.shadowLitType;
					break;
				// Point Light
				case CRYSTAL_LIGHT.POINT:
					_inst.enabled = _light.enabled;
					_inst.shaderType = _light.shaderType;
					_inst.color = _light.color;
					_inst.intensity = _light.intensity;
					_inst.inner = _light.inner;
					_inst.falloff = _light.falloff;
					_inst.radius = _light.radius;
					_inst.levels = _light.levels;
					_inst.castShadows = _light.castShadows;
					_inst.selfShadows = _light.selfShadows;
					_inst.penetration = _light.penetration;
					_inst.shadowPenumbra = _light.shadowPenumbra;
					_inst.shadowUmbra = _light.shadowUmbra;
					_inst.shadowScattering = _light.shadowScattering;
					_inst.shadowDepthOffset = _light.shadowDepthOffset;
					_inst.normalDistance = _light.normalDistance;
					_inst.diffuse = _light.diffuse;
					_inst.specular = _light.specular;
					_inst.litType = _light.litType;
					_inst.shadowLitType = _light.shadowLitType;
					break;
				// Sprite Light
				case CRYSTAL_LIGHT.SPRITE:
					_inst.enabled = _light.enabled;
					_inst.intensity = _light.intensity;
					_inst.sprite_index = asset_get_index(_light.sprite);
					_inst.image_xscale = _light.xScale;
					_inst.image_yscale = _light.yScale;
					_inst.image_angle = _light.angle;
					_inst.image_alpha = _light.alpha;
					_inst.image_blend = _light.color;
					_inst.image_index = _light.frame;
					_inst.image_speed = _light.animSpeed;
					_inst.castShadows = _light.castShadows;
					_inst.selfShadows = _light.selfShadows;
					_inst.penetration = _light.penetration;
					_inst.shadowPenumbra = _light.shadowPenumbra;
					_inst.shadowUmbra = _light.shadowUmbra;
					_inst.shadowScattering = _light.shadowScattering;
					_inst.shadowDepthOffset = _light.shadowDepthOffset;
					_inst.normalDistance = _light.normalDistance;
					_inst.diffuse = _light.diffuse;
					_inst.specular = _light.specular;
					_inst.litType = _light.litType;
					_inst.shadowLitType = _light.shadowLitType;
					break;
				// Spot Light
				case CRYSTAL_LIGHT.SPOT:
					_inst.enabled = _light.enabled;
					_inst.shaderType = _light.shaderType;
					_inst.color = _light.color;
					_inst.intensity = _light.intensity;
					_inst.inner = _light.inner;
					_inst.falloff = _light.falloff;
					_inst.radius = _light.radius;
					_inst.levels = _light.levels;
					_inst.angle = _light.angle;
					_inst.width = _light.width;
					_inst.spotFOV = _light.spotFOV;
					_inst.spotSmoothness = _light.spotSmoothness;
					_inst.spotDistance = _light.spotDistance;
					_inst.tilt = _light.tilt;
					//_inst.cookieTexture = _light.cookieTexture; // hmm
					_inst.castShadows = _light.castShadows;
					_inst.selfShadows = _light.selfShadows;
					_inst.penetration = _light.penetration;
					_inst.shadowPenumbra = _light.shadowPenumbra;
					_inst.shadowUmbra = _light.shadowUmbra;
					_inst.shadowScattering = _light.shadowScattering;
					_inst.shadowDepthOffset = _light.shadowDepthOffset;
					_inst.normalDistance = _light.normalDistance;
					_inst.diffuse = _light.diffuse;
					_inst.specular = _light.specular;
					_inst.litType = _light.litType;
					_inst.shadowLitType = _light.shadowLitType;
					break;
				// Shape Light
				case CRYSTAL_LIGHT.SHAPE:
					// add path from points
					var _points = _light.pathPoints;
					var _newPath = path_add();
					path_set_closed(_newPath, _light.pathClosed);
					var p = 0, _len = array_length(_points), _xx = 0, _yy = 0;
					while(p < _len) {
						_xx = _points[p++];
						_yy = _points[p++];
						path_add_point(_newPath, _xx, _yy, 100);
					}
					_inst.enabled = _light.enabled;
					_inst.shaderType = _light.shaderType;
					_inst.color = _light.color;
					_inst.colorOuter = _light.colorOuter;
					_inst.intensity = _light.intensity;
					_inst.inner = _light.inner;
					_inst.falloff = _light.falloff;
					_inst.radius = _light.radius;
					_inst.levels = _light.levels;
					_inst.angle = _light.angle;
					_inst.xScale = _light.xScale;
					_inst.yScale = _light.yScale;
					_inst.castShadows = _light.castShadows;
					_inst.selfShadows = _light.selfShadows;
					_inst.penetration = _light.penetration;
					_inst.shadowPenumbra = _light.shadowPenumbra;
					_inst.shadowUmbra = _light.shadowUmbra;
					_inst.shadowScattering = _light.shadowScattering;
					_inst.shadowDepthOffset = _light.shadowDepthOffset;
					_inst.normalDistance = _light.normalDistance;
					_inst.diffuse = _light.diffuse;
					_inst.specular = _light.specular;
					_inst.litType = _light.litType;
					_inst.path = _newPath;
					_inst.usingCustomPath = true;
					_inst.generate(); // the previous generation did nothing, because the path now exists
					break;
			}
			++i;
		}
		
		// update renderer culling
		var _currentRenderer = global.__CrystalCurrentRenderer;
		if (_currentRenderer != undefined) {
			_currentRenderer.__cullingDynamicsUpdateNow = true;
		}
	}
	
	// Backwards Compatibility
	//static __migrateV1toV2 = function(_json) {
	//	// < convert data here here >
	//	var _converted = _json;
	//	// send converted json format
	//	__load(_converted);
	//}
	#endregion
	
	#region Public Methods
	
	/// @desc Save JSON light data to a file.
	/// @method SaveBuffer(path, description)
	/// @param {String} path File path to save.
	/// @param {String} description File description.
	static SaveBuffer = function(_path, _description="Light Data") {
		var _json = __save(_description);
		var _buff = buffer_create(0, buffer_grow, 1);
		buffer_write(_buff, buffer_text, json_stringify(_json, true));
		if (file_exists(_path)) file_delete(_path);
		buffer_save(_buff, _path);
		buffer_delete(_buff);
	}
	
	/// @desc Load light data from JSON buffer file. This will parse and all lights will be created, including it's parameters.
	/// IMPORTANT: The loaded buffer is NOT deleted automatically. This function only reads the buffer. To prevent memory leak, consider deleting the loaded buffer later.
	/// @method LoadBuffer(buffer)
	/// @param {Id.Buffer} buffer The buffer with JSON data containing all light data. You could use buffer_load() or buffer_load_async().
	static LoadBuffer = function(_buffer) {
		if (!buffer_exists(_buffer)) {
			__crystal_trace($"ERROR loading Light Data. Invalid buffer: {_buffer}", 1);
			exit;
		}
		var _jsonString = buffer_read(_buffer, buffer_text);
		var _json = json_parse(_jsonString);
		var _version = _json.version;
		// load data based on version
		switch(_version) {
			case 1: __load(_json); break;
			//case 0: __migrateV1toV2(_json); break;
			default: __crystal_trace($"ERROR loading Light Data. Version not supported: v{_version}, supported: v{__versionMin}+", 1); break;
		}
	}
	
	#endregion
}
