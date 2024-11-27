
// Feather ignore all

/// @desc Creates a group of shadow sprites. Responsible for rendering Crystal_ShadowSprite() sprite shadows. Each Sprite Shadow Group creates a screen-space surface. This feature is EXPERIMENTAL.
/// For each different shadow sprite, a new vertex buffer is created and drawn (causing 1 vertex break for each).
/// @param {Enum.CRYSTAL_SHADOW_MODE} mode The shadow drawing mode. Example: CRYSTAL_SHADOW_MODE.SPRITE. (SPRITE_BAKED is EXPERIMENTAL!!!).
/// @param {Enum.CRYSTAL_SHADOW} shadowType Shadow type enum. Example: CRYSTAL_SHADOW.STATIC.
/// @param {Real} depth The depth at which all shadows in this group should be. You can use layer_get_depth() to place them on a room layer, for example.
/// @param {Real} alpha Shadows alpha. From 0 to 1.
/// @param {Real} sunAngle The angle of the sun. From 0 to 360. This is useful for directing shadows as if it were a sun.
/// @param {Real} renderResolution The render resolution of the shadows surface. Does not affect the depth buffer. Use lower resolution if using blur (useful for improving performance).
/// @param {Real} blurAmount The blur amount. From 0 to 1 or more. Use lower resolution to improve performance. When using 0, the blur shader is not even executed.
/// @param {Real} smoothBlur Enable it if you want shadows to blur smoothly.
/// @param {Bool} useAOpass If enabled, shadows will be rendered in the Ambient Occlusion pass instead of the Lightmap.
function Crystal_ShadowSpriteGroup(_mode, _shadowType, _depth, _alpha=0.5, _sunAngle=0, _renderResolution=1, _blurAmount=0, _smoothBlur=true, _useAOpass=false) constructor {
	// base
	__renderer = undefined;
	__timeSource = undefined;
	__applied = false;
	__surface = -1;
	__surfaceWidth = 0;
	__surfaceHeight = 0;
	__oldSurfaceWidth = 0;
	__oldSurfaceHeight = 0;
	__surfaceCamera = -1;
	__shadowsAmount = 0;
	__batchesAmount = 0;
	__shadows = []; // array of Crystal_ShadowSprite structs
	__batches = []; // array of vertex buffers. each vertex_submit supports 1 texture, then new vbuffs are generated if the texture page is different
	__vertexShadowsFormat = __crystalGlobal.vformatVertexSpriteShadows;
	__regenerate = true;
	mode = _mode;
	shadowType = _shadowType;
	self.depth = _depth;
	alpha = _alpha;
	sunAngle = _sunAngle;
	renderResolution = _renderResolution;
	blurAmount = _blurAmount;
	smoothBlur = _smoothBlur;
	useAOpass = _useAOpass;
	
	#region Private Methods
	
	/// @ignore
	static __addShadowSprite = function(_shadowSprite) {
		array_push(__shadows, _shadowSprite);
	}
	
	/// @ignore
	static __regenerateStaticShadows = function() {
		if (mode == CRYSTAL_SHADOW_MODE.SPRITE_BAKED && shadowType == CRYSTAL_SHADOW.STATIC) {
			__regenerate = true;
		}
	}
	
	/// @ignore
	__step = function() {
		// get shadows amount
		__shadowsAmount = array_length(__shadows);
		
		// Vertex-buffers generation
		if (__regenerate) {
			// vertex sprite shadows
			if (mode == CRYSTAL_SHADOW_MODE.SPRITE_BAKED) {
				// generate once for static shadows
				if (shadowType == CRYSTAL_SHADOW.STATIC) {
					__regenerate = false;
				}
				var _vFormat = __vertexShadowsFormat;
				var _currentTexture = -1;
				var _currentBatch = undefined;
				
				// delete previously created vertex buffers
				for (var v = 0; v < array_length(__batches); ++v) {
					vertex_delete_buffer(__batches[v].vBuff);
					array_delete(__batches, v, 1);
				}
				
				// loop shadows and add vertex buffers on-demand
				var i = 0, _shadowsArray = __shadows, _shadow = undefined;
				var _xx, _yy, _ww, _hh, _x1, _y1, _x2, _y2, _uvX1, _uvY1, _uvX2, _uvY2, _angle, spriteWidth, spriteHeight, spriteXoffset, spriteYoffset, _fullRot;
				repeat(__shadowsAmount) {
					with(_shadowsArray[i]) {
						if (!enabled) continue;
						if (__destroyed) {
							array_delete(_shadowsArray, i, 1); i--;
							continue;
						}
						
						// get current sprite texture
						__spriteTexture = sprite_get_texture(sprite, spriteSubimg);
						__spriteUVs = texture_get_uvs(__spriteTexture);//sprite_get_uvs(sprite, spriteSubimg);
						
						// if different texture, create a new vertex buffer
						if (_currentTexture != __spriteTexture) {
							_currentTexture = __spriteTexture;
							// finish previous vertex buffer
							if (_currentBatch != undefined) {
								vertex_end(_currentBatch);
							}
							// create a new vertex buffer and push to draw
							_currentBatch = vertex_create_buffer();
							array_push(other.__batches, {vBuff: _currentBatch, texture: _currentTexture});
							vertex_begin(_currentBatch, _vFormat);
						}
						
						// texture coordinates
						spriteWidth = sprite_get_width(sprite);
						spriteHeight = sprite_get_height(sprite);
						spriteXoffset = sprite_get_xoffset(sprite);
						spriteYoffset = sprite_get_yoffset(sprite);
						_uvX1 = __spriteUVs[0];
						_uvY1 = __spriteUVs[1];
						_uvX2 = __spriteUVs[2];
						_uvY2 = __spriteUVs[3];
						
						// local-space coordinates
						_fullRot = !fixedBase;
						_angle = -degtorad(angle);
						_xx = x + lengthdir_x(offsetX, offsetAngle);
						_yy = y + lengthdir_y(offsetY, offsetAngle);
						_ww = spriteWidth * xScale;
						_hh = spriteHeight * yScale;
						_x1 = -spriteXoffset;
						_y1 = -spriteYoffset * shadowLength;
						_x2 = -spriteXoffset + _ww;
						_y2 = -spriteYoffset + _hh;
						
						// Position XY, Width  |  UVx, UVy, localY, localY  |  angle, lockRot
						// Triangle 1
						vertex_float3(_currentBatch, _xx, _yy, dispersion);	vertex_float4(_currentBatch, _uvX1, _uvY1, _x1, _y1); vertex_float3(_currentBatch, _angle, 1, _fullRot); // top left
						vertex_float3(_currentBatch, _xx, _yy, dispersion);	vertex_float4(_currentBatch, _uvX2, _uvY1, _x2, _y1); vertex_float3(_currentBatch, _angle, 1, _fullRot); // top right
						vertex_float3(_currentBatch, _xx, _yy, 1);			vertex_float4(_currentBatch, _uvX1, _uvY2, _x1, _y2); vertex_float3(_currentBatch, _angle, _fullRot, _fullRot); // bottom left
						// Triangle 2
						vertex_float3(_currentBatch, _xx, _yy, 1);			vertex_float4(_currentBatch, _uvX1, _uvY2, _x1, _y2); vertex_float3(_currentBatch, _angle, _fullRot, _fullRot); // bottom left
						vertex_float3(_currentBatch, _xx, _yy, dispersion);	vertex_float4(_currentBatch, _uvX2, _uvY1, _x2, _y1); vertex_float3(_currentBatch, _angle, 1, _fullRot); // top right
						vertex_float3(_currentBatch, _xx, _yy, 1);			vertex_float4(_currentBatch, _uvX2, _uvY2, _x2, _y2); vertex_float3(_currentBatch, _angle, _fullRot, _fullRot); // bottom right
					}
					++i;
				}
				// finish last vertex buffer
				if (_currentBatch != undefined) {
					vertex_end(_currentBatch);
				}
			} else
			
			// sprite shadows (doesn't here)
			if (mode == CRYSTAL_SHADOW_MODE.SPRITE) {
				// generate once for static shadows
				if (shadowType == CRYSTAL_SHADOW.STATIC) {
					__crystal_trace("WARNING: 'Static' functionality does nothing for 'Sprite' shadow mode", 2);
					__regenerate = false;
				}
			}
		}
		
		// submit for rendering
		crystal_pass_submit(useAOpass ? CRYSTAL_PASS.MATERIAL : CRYSTAL_PASS.LIGHT, __render);
	}
	
	/// @ignore
	__render = function() {
		var _camera = view_get_camera(view_current); //camera_get_active();
		// Draw shadows
		gpu_push_state();
		//gpu_set_blendmode_ext_sepalpha(bm_one, bm_inv_src_alpha, bm_one, bm_one); // TRY THIS BLENDMODE LATER
		
		var _sourceSurf = __renderer.__sourceSurface;
		if (!surface_exists(_sourceSurf)) exit;
		
		// if different resolution, delete stuff to be updated
		var _surfaceWidth = surface_get_width(_sourceSurf);
		var _surfaceHeight = surface_get_height(_sourceSurf);
		if (__oldSurfaceWidth != _surfaceWidth || __oldSurfaceHeight != _surfaceHeight) {
			surface_free(__surface);
			__surfaceWidth = _surfaceWidth * renderResolution;
			__surfaceHeight = _surfaceHeight * renderResolution;
			__surfaceWidth -= frac(__surfaceWidth);
			__surfaceHeight -= frac(__surfaceHeight);
			__oldSurfaceWidth = _surfaceWidth;
			__oldSurfaceHeight = _surfaceHeight;
		}
		
		// Create surface and renderize shadows
		if (!surface_exists(__surface)) {
			__surface = surface_create(__surfaceWidth, __surfaceHeight);
		}
		surface_set_target(__surface);
			gpu_set_zwriteenable(false);
			draw_clear_alpha(c_black, 0);
			camera_apply(_camera);
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
			
			// sprite
			if (mode == CRYSTAL_SHADOW_MODE.SPRITE) {
				var _sunAngle = sunAngle;
				var i = 0, _shadowsArray = __shadows, _shadow = undefined;
				repeat(__shadowsAmount) {
					with(_shadowsArray[i]) {
						if (!enabled) continue;
						if (__destroyed) {
							array_delete(_shadowsArray, i, 1); i--;
							continue;
						}
						draw_sprite_ext(sprite, spriteSubimg, x+lengthdir_x(offsetX, offsetAngle), y+lengthdir_y(offsetY, offsetAngle), xScale*shadowLength, yScale, angle+_sunAngle*followSun, c_black, 1);
					}
					++i;
				}
			} else
			
			// vertex-based
			if (mode == CRYSTAL_SHADOW_MODE.SPRITE_BAKED) {
				static _u_shadowParams = shader_get_uniform(__cle_shSpriteShadow, "u_params"); // shadowScattering
				
				// draw vertex buffers
				gpu_set_cullmode(cull_noculling);
				shader_set(__cle_shSpriteShadow);
					shader_set_uniform_f(_u_shadowParams, -degtorad(sunAngle), 1, 1);
					var b = 0, bsize = array_length(__batches), _batch = undefined;
					repeat(bsize) {
						_batch = __batches[b];
						vertex_submit(_batch.vBuff, pr_trianglelist, _batch.texture);
						++b;
					}
				shader_reset();
				gpu_set_cullmode(cull_counterclockwise);
			}
		surface_reset_target();
		
		// Draw shadowmap surface on screen (and with blur, if available) - we are in world-space (inside Renderer)
		//gpu_set_blendmode(bm_normal);
		// create a temporary orthographic camera to draw the surface on the screen
		if (__surfaceCamera == -1) {
			__surfaceCamera = camera_create_view(0, 0, __surfaceWidth, __surfaceHeight);
		} else {
			camera_set_view_size(__surfaceCamera, __surfaceWidth, __surfaceHeight);
		}
		camera_apply(__surfaceCamera);
		var _oldDepth = gpu_get_depth();
		gpu_set_depth(depth);
		if (useAOpass) gpu_set_colorwriteenable(false, false, true, true); // draw to AO pass
		//gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
		if (blurAmount > 0) {
			gpu_set_tex_filter(smoothBlur);
			static _u_blurTexelSize = shader_get_uniform(__cle_shShadowBlur, "u_texelSize");
			static _u_blurAmount = shader_get_uniform(__cle_shShadowBlur, "u_blurAmount");
			shader_set(__cle_shShadowBlur);
			shader_set_uniform_f(_u_blurTexelSize, 1/__surfaceWidth, 1/__surfaceHeight);
			shader_set_uniform_f(_u_blurAmount, blurAmount);
			draw_surface_stretched_ext(__surface, 0, 0, __surfaceWidth, __surfaceHeight, c_white, alpha);
			shader_reset();
		} else {
			draw_surface_stretched_ext(__surface, 0, 0, __surfaceWidth, __surfaceHeight, c_white, alpha);
		}
		gpu_set_depth(_oldDepth);
		gpu_pop_state();
		
		// Re-apply current camera matrix
		camera_apply(_camera);
	}
	
	#endregion
	
	#region Public Methods
	/// @desc Call this after setting up the Shadow Sprite Group and it will be sent to the last created renderer (or set with `crystal_set_renderer()`).
	/// @method Apply(renderer)
	/// @param {Struct.Crystal_Renderer} renderer The renderer to add the group for rendering.
	static Apply = function(_renderer=global.__CrystalCurrentRenderer) {
		// check
		if (__applied) return;
		if (_renderer == undefined) {
			__crystal_trace("Shadow not created, renderer not found. (creation order?)", 1);
			return;
		}
		__renderer = _renderer;
		// initialize function execution for this layer renderer
		if (__timeSource == undefined) {
			__timeSource = time_source_create(time_source_game, 1, time_source_units_frames, __step, [], -1);
			time_source_start(__timeSource);
		}
		__applied = true;
	}
	
	/// @desc Destroys the shadow group from memory. You should call this when you change rooms, for example. Useful for the Clean-Up Event.
	/// It is possible to call .Apply() again after calling this function.
	static Destroy = function() {
		// destroy step time source
		if (__timeSource != undefined) {
			time_source_destroy(__timeSource);
		}
		array_resize(__shadows, 0);
		var i = 0, isize = array_length(__batches);
		repeat(isize) {
			vertex_delete_buffer(__batches[i].vBuff);
			++i;
		}
		if (__surfaceCamera != -1) camera_destroy(__surfaceCamera);
		__applied = false;
		return self;
	}
	
	/// @desc Sets the rendering resolution for shadows. Lower resolution improves blur performance.
	/// @method SetRenderResolution(resolution)
	/// @param {Real} resolution Resolution, from 0 to 1 (full);
	static SetRenderResolution = function(_resolution=1) {
		renderResolution = clamp(_resolution, 0.1, 1);
		__oldSurfaceWidth = 0; // reset old resolution, so we can simulate a resize
		__oldSurfaceHeight = 0;
	}
	
	/// @desc Use this function to make all shadows of this group follow a position, instance or object. Please note, it is only possible to follow a single instance (position) per group.
	/// 
	/// This function sets the offsetX, offsetY and offsetAngle of all shadow sprites automatically - doing an override. This is only useful for point shadows. For directional shadows, use sunAngle from the group instead. 
	/// @method FollowPoint(xOrObject, y, weight)
	/// @param {Real,Id.Instance,Asset.GMObject} objectOrX x position, object or Instance to follow.
	/// @param {Real} y The y position to follow (optional).
	/// @param {Real} weight The distance weight. Defines how much the shadow offset will move away. Generally 0 - 1. Use 0 to not do the offset.
	static FollowPoint = function(_xOrObject, _y=0, _weight=0.3) {
		var i = 0, _shadowsArray = __shadows, _shadow = undefined;
		var _xT, _yT, _wh = _weight, _dist;
		if (instance_exists(_xOrObject)) {
			_xT = _xOrObject.x;
			_yT = _xOrObject.y;
		} else {
			_xT = _xOrObject;
			_yT = _y;
		}
		repeat(__shadowsAmount) {
			with(_shadowsArray[i]) {
				if (!enabled) continue;
				offsetAngle = point_direction(_xT, _yT, x, y);
				if (_wh > 0) {
					_dist = point_distance(_xT, _yT, x, y) * _wh;
					offsetX = _dist;
					offsetY = _dist;
				}
			}
			++i;
		}
	}
	#endregion
}

/// @desc Creates a sprite-type shadow. A shadow is where it says where light will be blocked.
/// @param {Id.Instance,Struct} startId The instance to get default properties. Use noone if you want to use default properties (position, angle and depth: 0, scale: 1).
/// @param {Asset.GMSprite} sprite The sprite to be used as shadow.
/// @param {Real} spriteSubimg The sprite subimg (frame).
function Crystal_ShadowSprite(_startId, _sprite, _spriteSubimg) constructor {
	static defaultOwner = {x : 0, y : 0, image_angle : 0, image_xscale : 1, image_yscale : 1};
	if (!instance_exists(_startId)) {
		_startId = defaultOwner;
	}
	// variables
	enabled = true;
	followSun = true;
	fixedBase = false;
	self.x = _startId.x;
	self.y = _startId.y;
	offsetX = 0;
	offsetY = 0;
	offsetAngle = 0;
	angle = _startId.image_angle;
	xScale = _startId.image_xscale;
	yScale = _startId.image_yscale;
	sprite = _sprite;
	spriteSubimg = _spriteSubimg;
	shadowLength = 1; // useful for vertex shadows
	dispersion = 1; // default is 1!
	
	// misc
	__destroyed = false;
	__applied = false;
	__spriteUVs = undefined;
	__spriteTexture = undefined;
	__group = undefined;
	
	/// @desc Add shadow sprite to the group.
	/// @method Apply(group)
	/// @param {Struct.Crystal_ShadowSpriteGroup} group The group to add the shadow.
	static Apply = function(_group) {
		// check
		if (__applied) return;
		if (_group == undefined) {
			__crystal_trace("Sprite Shadow not created, group not found.", 1);
			return;
		}
		__group = _group;
		// add to group (once)
		_group.__addShadowSprite(self);
		__applied = true;
		__destroyed = false;
	}
	
	static Destroy = function() {
		if (__group != undefined) __group.__regenerateStaticShadows();
		__destroyed = true;
		__applied = false;
	}
}
