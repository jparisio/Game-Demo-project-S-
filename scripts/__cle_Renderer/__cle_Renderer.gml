
// Feather ignore all

/// @desc Deferred renderer for generating lights, materials and shadows. Here contains the essential stuff to make the lighting & shadows system work (including PBR rendering).
///
/// The renderer is smart and tries to clean up memory when things are deleted, but you should always run .Destroy() in the Clean Up event.
/// 
/// If you're making a split-screen game, you necessarily need two renderers, one for each view port. And when rendering, you will use different cameras to render content. And you will draw the renderer in its appropriate viewport for each player.
/// If you are creating shadow casters, you will have to send each thing to different renderers. You will have to send it more than once, for each one, for example. None of this applies if your game is single player.
/// You may also need two post-processing renderer for each lighting renderer.
function Crystal_Renderer() constructor {
	// Copyright (C) 2024, Mozart Junior (FoxyOfJungle)
	__crystal_trace("Renderer created", 2);
	// Init
	__renderSurfaceWidth = 0;
	__renderSurfaceHeight = 0;
	__renderSurfaceOldWidth = 0;
	__renderSurfaceOldHeight = 0;
	__sourceSurface = -1;
	__sourceCamera = -1;
	__allowRendering = true;
	__preRenderUndefined = true;
	__cpuFrameTime = 0;
	__gpuVRAMusage = 0;
	
	// Configs (do NOT edit it here - use appropriate functions)
	__isDrawEnabled = true;
	__isRenderEnabled = true;
	__isInterpolated = false;
	__isMaterialsEnabled = false;
	__isHDREnabled = false;
	__isHDRLightmapEnabled = true;
	__isSSREnabled = false;
	__isGeneratingLightsCollision = false;
	__isDitheringEnabled = false;
	__isCullingEnabled = true;
	__cullingDynamicsViewBorderSize = 200;
	__cullingDynamicsViewMoveDistance = 10;
	__cullingDynamicsAutoUpdateTimerBase = 60;
	__cullingDynamicsAutoUpdateTimer = __cullingDynamicsAutoUpdateTimerBase;
	__cullingDynamicsOldCamX = 0;
	__cullingDynamicsOldCamY = 0;
	__cullingDynamicsOldCamW = 0;
	__cullingDynamicsOldCamH = 0;
	__cullingStaticsOldCamX = 0;
	__cullingStaticsOldCamY = 0;
	__cullingStaticsViewBorderSize = 2500;
	__cullingStaticsViewMoveDistance = 250;
	__cullingDynamicsUpdateNow = false;
	__ssrAlpha = 1;
	__ssrSky = -1;
	__ssrSkySubimg = 0;
	__ssrSkyAlpha = 1;
	__ssrSkyColor = c_white;
	__surfaceFormatBase = surface_rgba8unorm;
	__surfaceFormat = __surfaceFormatBase;
	__renderResolution = 1;
	__renderOldResolution = __renderResolution;
	__ambientLightColor = c_black;
	__ambientLightColorShader = __crystal_get_color_rgb(__ambientLightColor);
	__ambientLightIntensity = 0;
	__ambientLutTexBase = sprite_get_texture(__cle_sprNeutralLUT, 0);
	__ambientLutTex = __ambientLutTexBase;
	__ambientLutTexUVs = texture_get_uvs(__ambientLutTex);
	__ambientLutWidth = 512;
	__ambientLutHeight = 512;
	__ambientLutTilesH = 8;
	__ambientLutTilesV = 8;
	__ditheringSprite = __cle_sprBayer2x2;
	__ditheringBayerSize = sprite_get_width(__ditheringSprite);
	__ditheringBayerTex = sprite_get_texture(__ditheringSprite, 0);
	__ditheringBayerTexUVs = texture_get_uvs(__ditheringBayerTex);
	__ditheringBitLevels = 3;
	__ditheringThreshold = 0;
	__lightsIntensity = 1;
	__lightsBlendMode = 0;
	
	// Render passes
	__renderPass[CRYSTAL_PASS.LIGHT] = {name : "Light Map", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPass[CRYSTAL_PASS.NORMALS] = {name : "Normals", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPass[CRYSTAL_PASS.MATERIAL] = {name : "Material", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPass[CRYSTAL_PASS.EMISSIVE] = {name : "Emissive", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPass[CRYSTAL_PASS.REFLECTIONS] = {name : "Reflections", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPass[CRYSTAL_PASS.COMBINE] = {name : "Combine", surface : -1, resolution : 1, renderables : ds_list_create()};
	__renderPassAmount = array_length(__renderPass);
	__deferredFunction = undefined;
	__surfaceCamera = -1;
	__lightmapBuffer = undefined;
	__lightmapBufferUpdateTimeBase = 5;
	__lightmapBufferUpdateTime = __lightmapBufferUpdateTimeBase;
	__lightmapBytesPerPixel = 4;
	__lightmapSurfaceWidth = 0; // read only
	__lightmapSurfaceHeight = 0;
	__lightmapSurfaceTex = -1;
	__normalmapSurfaceTex = -1;
	__materialSurfaceTex = -1;
	__emissiveSurfaceTex = -1;
	__reflectionsSurfaceTex = -1;
	__finalRenderSurf = -1; // this is just for reference!
	__textureWhite = __crystalGlobal.textureWhite;
	__textureBlack = __crystalGlobal.textureBlack;
	__textureNormal = __crystalGlobal.textureNormal;
	__textureMaterial = __crystalGlobal.textureMaterial;
	
	// Layer Materials (array with structs)
	__matNormalLayers = ds_list_create();
	__matMaterialLayers = ds_list_create();
	__matEmissiveLayers = ds_list_create();
	__matReflectionLayers = ds_list_create();
	__matLightLayers = ds_list_create();
	__matCombineLayers = ds_list_create();
	// Materials (array with structs)
	__matNormalSprites = ds_list_create();
	__matEmissiveSprites = ds_list_create();
	__matReflectionSprites = ds_list_create();
	__matMetallicSprites = ds_list_create();
	__matRoughnessSprites = ds_list_create();
	__matAoSprites = ds_list_create();
	__matMaskSprites = ds_list_create();
	
	// Shadows-related
	__shadowVertexFormat = __crystalGlobal.vformatVertexShadows;
	__vbuffStatic = undefined;
	__vbuffStaticRebuild = false;
    __vbuffDynamic = undefined;
	__staticShadowsArray = ds_list_create();
    __dynamicShadowsArray = ds_list_create();
	
	// define current renderer to self
	global.__CrystalCurrentRenderer = self;
	
	#region Internal Methods
	/// @ignore
	static __cleanSurfaces = function() {
		var i = 0, _surf = undefined;
		repeat(__renderPassAmount) {
			_surf = __renderPass[i].surface;
			if (surface_exists(_surf)) surface_free(_surf);
			++i;
		}
	}
	
	/// @ignore
	static __addShadowCaster = function(_shadow) {
		switch(_shadow.__type) {
			case CRYSTAL_SHADOW.STATIC: ds_list_insert(__staticShadowsArray, 0, _shadow); __vbuffStaticRebuild = true; break;
			case CRYSTAL_SHADOW.DYNAMIC: ds_list_insert(__dynamicShadowsArray, 0, _shadow); break;
			default: __crystal_trace($"ShadowCaster failed to be added. Unknown type {_shadow.__type}", 1); exit; break;
		}
	}
	
	/// @ignore
	static __addMaterialLayer = function(_materialLayer) {
		// crystal layers (if any)
		switch(_materialLayer.__pass) {
			case CRYSTAL_PASS.NORMALS: ds_list_insert(__matNormalLayers, 0, _materialLayer); break;
			case CRYSTAL_PASS.EMISSIVE: ds_list_insert(__matEmissiveLayers, 0, _materialLayer); break;
			case CRYSTAL_PASS.MATERIAL: ds_list_insert(__matMaterialLayers, 0, _materialLayer); break;
			case CRYSTAL_PASS.REFLECTIONS: ds_list_insert(__matReflectionLayers, 0, _materialLayer); break;
			case CRYSTAL_PASS.LIGHT: ds_list_insert(__matLightLayers, 0, _materialLayer); break;
			case CRYSTAL_PASS.COMBINE: ds_list_insert(__matCombineLayers, 0, _materialLayer); break;
			default: __crystal_trace($"MaterialLayer failed to be added. Unknown type {_materialLayer.__type}", 1); exit; break;
		}
	}
	
	/// @ignore
	static __addMaterial = function(_material) {
		// sprites (if any)
		if (_material.normalSprite != undefined) ds_list_insert(__matNormalSprites, 0, _material); // passar o __matNormalSprites para dentro do __renderPass!! (investigar como acessar de forma eficiente)
		if (_material.emissiveSprite != undefined) ds_list_insert(__matEmissiveSprites, 0, _material);
		if (_material.aoSprite != undefined) ds_list_insert(__matAoSprites, 0, _material);
		if (_material.roughnessSprite != undefined) ds_list_insert(__matRoughnessSprites, 0, _material);
		if (_material.metallicSprite != undefined) ds_list_insert(__matMetallicSprites, 0, _material);
		if (_material.reflectionSprite != undefined) ds_list_insert(__matReflectionSprites, 0, _material);
		if (_material.maskSprite != undefined) ds_list_insert(__matMaskSprites, 0, _material);
	}
	
	/// @ignore
	static __calculateVRAM = function() {
		__gpuVRAMusage = 0;
		
		// Surfaces
		// passes
		// 8 bits = 1 byte per channel. 16 bits = 2 bytes per channel.
		// RGBA = 4 channels. 4 * 1 = 4 | 4 * 2 = 8.
		// If Depth Buffer + Stencil is enabled, its 2x the surface size.
		var i = 0, isize = __renderPassAmount, _pass = undefined, _surf = undefined, _width = undefined, _height = undefined, _format = undefined;
		repeat(isize) {
			_pass = __renderPass[i];
			_surf = _pass.surface;
			if (surface_exists(_surf)) {
				_width = surface_get_width(_surf);
				_height = surface_get_height(_surf);
				var _bytesPerFormat = __crystal_surface_format_get_size(_surf);
				var _hasDepthBufferAndStencil = surface_has_depth(_surf) ? 2 : 1;
				__gpuVRAMusage += _width * _height * _bytesPerFormat * _hasDepthBufferAndStencil;
			}
			i++;
		}
		// material layers
		var _materialLayers = [__matNormalLayers, __matMaterialLayers, __matReflectionLayers, __matEmissiveLayers, __matLightLayers, __matCombineLayers];
		var m = 0, msize = array_length(_materialLayers), _matLayer = undefined;
		repeat(msize) {
			_matLayer = _materialLayers[m];
			var l = 0, lsize = ds_list_size(_matLayer);
			repeat(lsize) {
				_surf = _matLayer[| l].__surface;
				if (surface_exists(_surf)) {
					_width = surface_get_width(_surf);
					_height = surface_get_height(_surf);
					var _bytesPerFormat = __crystal_surface_format_get_size(_surf);
					var _hasDepthBufferAndStencil = surface_has_depth(_surf) ? 2 : 1;
					__gpuVRAMusage += _width * _height * _bytesPerFormat * _hasDepthBufferAndStencil;
				}
				++l;
			}
			++m;
		}
		
		// Vertex buffers
		var _vertexBuffers = [__vbuffStatic, __vbuffDynamic];
		i = 0; isize = array_length(_vertexBuffers);
		repeat(isize) {
			__gpuVRAMusage += vertex_get_buffer_size(_vertexBuffers[i]);
			++i;
		}
		
		// Light data
		with(__cle_objShapeLight) {
			if (vertexBuffer != undefined) {
				other.__gpuVRAMusage += vertex_get_buffer_size(vertexBuffer);
			}
		}
	}
	
	#endregion
	
	#region Public Methods
	#region GENERAL
	/// @desc Destroy the Renderer from memory. Including vertex shadows vertex buffer, collision buffer and pass surfaces.
	/// @method Destroy()
	static Destroy = function() {
		if (__vbuffStatic != undefined) vertex_delete_buffer(__vbuffStatic);
		if (__vbuffDynamic != undefined) vertex_delete_buffer(__vbuffDynamic);
		if (__lightmapBuffer != undefined) buffer_delete(__lightmapBuffer);
		var i = 0;
		repeat(__renderPassAmount) {
			ds_list_destroy(__renderPass[i++].renderables);
		}
		__cleanSurfaces();
		ds_list_destroy(__staticShadowsArray);
		ds_list_destroy(__dynamicShadowsArray);
		ds_list_destroy(__matNormalLayers);
		ds_list_destroy(__matMaterialLayers);
		ds_list_destroy(__matEmissiveLayers);
		ds_list_destroy(__matReflectionLayers);
		ds_list_destroy(__matLightLayers);
		ds_list_destroy(__matCombineLayers);
		ds_list_destroy(__matNormalSprites);
		ds_list_destroy(__matEmissiveSprites);
		ds_list_destroy(__matReflectionSprites);
		ds_list_destroy(__matMetallicSprites);
		ds_list_destroy(__matRoughnessSprites);
		ds_list_destroy(__matAoSprites);
		ds_list_destroy(__matMaskSprites);
		__crystal_trace("Lighting renderer destroyed", 2);
	}
	#endregion
	
	#region SETTERS
	/// @desc By default, Crystal disables everything outside of the camera. This function allows you to disable this.
	/// This function enables the culling feature, which allows you to disable Lights, Materials, and Shadow Casters outside of the camera. Note that "Material Layers", "Renderables" and other things are not touched, just the mentioned.
	/// This function will disable ALL dynamic lights (excluding Direct lights only), so you should enable them again with instance_activate_region() for example.
	/// Culling only disables things when the camera is moving. Note that this is not performed every frame, but the system tracks the deactivation speed as the camera moves faster, to avoid things disappearing and appearing quickly.
	/// NOTE: This implementation is just a stopgap, unfortunately huge (giant) worlds will suffer if you have too many things going at once, since the loop is performed by all items at once. Quadtrees would probably be more efficient, but this will be investigated in the future.
	/// @method SetCullingEnable(enabled)
	/// @param {Bool} enabled Defines if culling is enabled. Use -1 to toggle.
	static SetCullingEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isCullingEnabled = !__isCullingEnabled;
		} else {
			__isCullingEnabled = _enabled;
		}
	}
	
	/// @desc Defines the culling settings only.
	/// @method SetCullingSettings(borderDistance, moveMaxDistance, autoUpdateTimer)
	/// @param {Real} borderDistance Sets the distance from the camera's edge at which stuff will stop from rendering. Default is 100. Increase this if you notice some things disappearing sooner.
	/// @param {Real} moveMaxDistance Distance the camera needs to move to update the culling of things. Default is 10. Useful to avoid constant updates every frame. If the camera teleports, this should work naturally too.
	/// @param {Real} autoUpdateTimer The time (in frames) that the culling state should update if the camera is idle (not moving).
	static SetCullingSettings = function(_borderDistance=200, _moveMaxDistance=10, _autoUpdateTimer=60) {
		__cullingDynamicsViewBorderSize = _borderDistance;
		__cullingDynamicsViewMoveDistance = _moveMaxDistance;
		__cullingDynamicsAutoUpdateTimerBase = _autoUpdateTimer;
	}
	
	/// @desc Enable or disable materials rendering of the lighting system. This includes: Normal Maps, Emissive, Reflections and PBR (metallic, roughness and ambient occlusion).
	/// Note that naturally materials are only created when in use, but this function completely disables the feature, as if it did not exist in the lighting system.
	/// This improves performance if you just want to have lights with shadows.
	/// @method SetMaterialsEnable(enabled)
	/// @param {Bool} enabled Defines if the material rendering is enabled. Use -1 to toggle.
	static SetMaterialsEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isMaterialsEnabled = !__isMaterialsEnabled;
		} else {
			__isMaterialsEnabled = _enabled;
		}
		__cleanSurfaces();
	}
	
	/// @desc Enable or disable HDR in general (including lights). Default is false. Generally recommended to have (if needed), for best visuals. With HDR enabled, the lights can have more contrasting and visually beautiful intensity and you have better control of emissive materials.
	/// 
	/// NOTE: This does not affect, specifically: Normal Maps, Reflections or Materials (Metallic + Roughness + Ambient Occlusion + Mask), since they do not need this feature.
	/// 
	/// This can affect VRAM usage and not every hardware supports this (although, most of the 2015 GPUs above should work).
	/// @method SetHDREnable(enabled)
	/// @param {Bool,Real} enabled Defines if HDR is enabled. Use -1 to toggle.
	static SetHDREnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isHDREnabled = !__isHDREnabled;
		} else {
			__isHDREnabled = _enabled;
		}
		// Check
		if (__isHDREnabled) {
			if (surface_format_is_supported(CLE_CFG_HDR_TEXTURE_FORMAT)) {
				__surfaceFormat = CLE_CFG_HDR_TEXTURE_FORMAT;
			} else {
				__crystal_trace($"WARNING: Texture format is not supported on current platform! Using RGBA8 (default).", 2);
				__surfaceFormat = __surfaceFormatBase;
			}
		} else {
			__surfaceFormat = __surfaceFormatBase;
		}
		// Recreate surfaces (if exists) with the new texture format
		// passes
		__cleanSurfaces();
		// material layers
		var l = 0, lsize = ds_list_size(__matEmissiveLayers);
		repeat(lsize) {
			_surf = __matEmissiveLayers[l].__surface;
			if (surface_exists(_surf)) surface_free(_surf);
			++l;
		}
		l = 0; lsize = ds_list_size(__matLightLayers);
		repeat(lsize) {
			_surf = __matLightLayers[l].__surface;
			if (surface_exists(_surf)) surface_free(_surf);
			++l;
		}
		l = 0; lsize = ds_list_size(__matCombineLayers);
		repeat(lsize) {
			_surf = __matCombineLayers[l].__surface;
			if (surface_exists(_surf)) surface_free(_surf);
			++l;
		}
	}
	
	/// @desc Enable or Disable HDR lightmap. Default is true. With HDR enabled, the lights can have more contrasting and visually beautiful intensity. When deactivated, light intensities can only go up to 1 clamped.
	/// @method SetLightsHDREnable(enabled)
	/// @param {Bool,Real} enabled Defines if Lightmap HDR is enabled. Use -1 to toggle.
	static SetLightsHDREnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isHDRLightmapEnabled = !__isHDRLightmapEnabled;
		} else {
			__isHDRLightmapEnabled = _enabled;
		}
		var _surf = __renderPass[CRYSTAL_PASS.LIGHT].surface;
		if (surface_exists(_surf)) surface_free(_surf); // recreate lightmap with new texture format
	}
	
	/// @desc Sets lights blend mode.
	/// WARNING: Blendmode 2 is experimental and may change in future updates.
	/// @method SetLightsBlendmode(blendMode)
	/// @param {Real} blendMode Blendmode to blend lights. 0 = Multiply, 1 = Multiply Normalized, 2 = Multiply Linear, 3 = Add.
	static SetLightsBlendmode = function(_blendMode=0) {
		__lightsBlendMode = _blendMode;
	}
	
	/// @desc Sets intensity of all lights.
	/// @param {Real} intensity Lights intensity. From 0 to 1. 1 is fully lit.
	/// @method SetLightsIntensity(intensity)
	static SetLightsIntensity = function(_intensity) {
		__lightsIntensity = _intensity;
	}
	
	/// @desc Enables or disables the generation of lights collision information. Only enable this if you actually intend to use it, as there is a performance cost.
	/// @method SetLightsCollisionEnable(enabled)
	/// @param {Bool} enabled Defines if the lightmap is generating collisiong data. Use -1 to toggle.
	static SetLightsCollisionEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isGeneratingLightsCollision = !__isGeneratingLightsCollision;
		} else {
			__isGeneratingLightsCollision = _enabled;
		}
	}
	
	/// @desc Defines the lights collision buffer generation settings only.
	/// @method SetLightsCollisionSettings(updateTime)
	/// @param {Real} updateTime The time (in frames) that the collision buffer should be updated.
	static SetLightsCollisionSettings = function(_updateTime) {
		__lightmapBufferUpdateTime = _updateTime;
	}
	
	/// @desc Sets the ambient light color. The default is c_black. The ambient color is on top of the LUT colors.
	/// @method SetAmbientColor(color)
	/// @param {Real,Color} color The ambient color.
	static SetAmbientColor = function(_color) {
		__ambientLightColor = _color;
		__ambientLightColorShader = __crystal_get_color_rgb(__ambientLightColor);
	}
	
	/// @desc Sets the ambient light intensity. The ambient illumination is mixed after LUT. You can use values greater than 1, but from 0 to 1 is the recommended.
	/// @method SetAmbientIntensity(intensity)
	/// @param {Real} intensity The ambient intensity.
	static SetAmbientIntensity = function(_intensity) {
		__ambientLightIntensity = max(_intensity, 0);
	}
	
	/// @desc Defines a LUT texture to be used by the lighting system. It will serve as the ambient light color.
	/// @method SetAmbientLUT(textureId)
	/// @param {Pointer.Texture} textureId Id of the texture to be used as a LUT. Example: sprite_get_texture() or surface_get_texture(). Use undefined or -1 to use the default LUT.
	/// @param {Real} type The LUT type to be used.  0: Strip, 1: Grid, 2: Hald Grid (Cube).
	/// @param {Real} horizontalSquares Horizontal LUT squares. Example: 16 (Strip), 8 (Grid), 8 (Hald Grid).
	static SetAmbientLUT = function(_textureId, _type=1, _horizontalSquares=8) {
		if (_textureId == undefined || _textureId < 0) {
			_textureId = __ambientLutTexBase;
		}
		__ambientLutTex = _textureId;
		__ambientLutTexUVs = texture_get_uvs(__ambientLutTex);
		if (_type == 0) {
			// Strip
			__ambientLutTilesH = _horizontalSquares;
			__ambientLutTilesV = 1;
			__ambientLutWidth = _horizontalSquares * _horizontalSquares;
			__ambientLutHeight = _horizontalSquares;
		} else
		if (_type == 1) {
			// Grid
			__ambientLutTilesH = _horizontalSquares;
			__ambientLutTilesV = _horizontalSquares;
			__ambientLutWidth = _horizontalSquares * _horizontalSquares * _horizontalSquares;
			__ambientLutHeight = __ambientLutWidth;
		} else
		if (_type == 2) {
			// Hald Grid
			__ambientLutTilesH = _horizontalSquares;
			__ambientLutTilesV = _horizontalSquares * _horizontalSquares;
			__ambientLutWidth = _horizontalSquares * _horizontalSquares * _horizontalSquares;
			__ambientLutHeight = __ambientLutWidth;
		}
	}
	
	/// @desc Sets whether to enable Screen-Space Reflections (SSR). With this enabled, you can reflect the scene or sky onto reflective materials (only works with BRDF shaders).
	/// @method SetSSREnable(enabled)
	/// @param {Bool} enabled Toggle SSR. Use -1 to toggle.
	static SetSSREnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isSSREnabled = !__isSSREnabled;
		} else {
			__isSSREnabled = _enabled;
		}
	}
	
	/// @desc Defines the screen-space reflections settings only.
	/// @method SetSSRSettings(ssrIntensity, spriteOrSurface, subimg, color, alpha)
	/// @param {Real} ssrIntensity Screen-space reflections intensity. 0 to 1.
	/// @param {Asset.GMSprite,Id.Surface} spriteOrSurface The sprite asset or surface to be used as sky.
	/// @param {Real} subimg If using a sprite, this is the sky sprite subimg (frame).
	/// @param {Color} color The sky color.
	/// @param {Real} alpha The sky alpha. 0 to 1.
	static SetSSRSettings = function(_ssrIntensity, _spriteOrSurface, _subimg=0, _color=c_white, _alpha=1) {
		__ssrAlpha = _ssrIntensity;
		__ssrSky = _spriteOrSurface;
		__ssrSkySubimg = _subimg;
		__ssrSkyColor = _color;
		__ssrSkyAlpha = _alpha;
	}
	
	/// @desc Defines whether the dithering effect for lights and shadows is enabled or not. For performance reasons, dithering is disabled by default at compile time, so you can enable it directly in the shader: "__cle_shDeferredRender", through the "ENABLE_DITHERING" option. This way, you will be able to use this function.
	/// Note that by default, Crystal does not enable dithering at compile time, for performance reasons. You need to uncomment "#define ENABLE_DITHERING" in the "__cle_shDeferredRender" shader.
	/// @method SetDitheringEnable(enabled)
	/// @param {Bool} enabled Toggle dithering. true or false. Use -1 to toggle.
	static SetDitheringEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isDitheringEnabled = !__isDitheringEnabled;
		} else {
			__isDitheringEnabled = _enabled;
		}
	}
	
	/// @desc Sets the parameters of the dithering effect only.
	/// @method SetDitheringSettings(threshold, bayerSprite, bayerSpriteSubimg, levels)
	/// @param {Real} threshold Defines when dithering should be applied.
	/// @param {Asset.GMSprite} bayerSprite A bayer matrix sprite for the dithering effect. Crystal contains some included in the "Assets" folder.
	/// @param {Real} bayerSpriteSubimg Bayer sprite subimg (frame).
	/// @param {Real} levels Posterization level. Recommended 3 - 8 maybe (use what you want). Above 256 it is not noticeable.
	static SetDitheringSettings = function(_threshold=0, _bayerSprite=__cle_sprBayer2x2, _bayerSpriteSubimg=0, _levels=8) {
		__ditheringThreshold = _threshold;
		__ditheringSprite = _bayerSprite;
		__ditheringBayerSize = sprite_get_width(__ditheringSprite);
		__ditheringBayerTex = sprite_get_texture(__ditheringSprite, _bayerSpriteSubimg);
		__ditheringBayerTexUVs = texture_get_uvs(__ditheringBayerTex);
		__ditheringBitLevels = _levels;
	}
	
	/// @desc Sets the rendering resolution for shadows and lights.
	/// @method SetRenderResolution(resolution)
	/// @param {Real} resolution Resolution, from 0 to 1 (full).
	static SetRenderResolution = function(_resolution=1) {
		__renderResolution = clamp(_resolution, 0.1, 1);
		__renderSurfaceOldWidth = 0; // reset old resolution, so we can simulate a resize
		__renderSurfaceOldHeight = 0;
	}
	
	/// @desc Sets the render resolution of an individual pass. A value from 0 to 1. Each pass has the resolution of the input surface multiplied by this resolution variable.
	/// PLEASE NOTE: Changing the resolution of individual passes will cause the depth buffer to not work properly if you have it enabled. This is expected and is not a bug! It's not Crystal's fault either, just the way the graphics pipeline works.
	/// @method SetPassResolution(resolution)
	/// @param {Enum.CRYSTAL_PASS} pass The crystal pass to change the render resolution.
	/// @param {Real} resolution Resolution, from 0 to 1 (full);
	static SetPassResolution = function(_pass, _resolution=1) {
		var _p = __renderPass[_pass];
		_p.resolution = clamp(_resolution, 0.1, 1);
		if (surface_exists(_p.surface)) surface_free(_p.surface); // will be recreated with the new resolution in the Render
	}
	
	/// @desc Define your own final rendering class with a custom shader for custom effects.
	/// @method SetRenderClass(renderClass)
	/// @param {Struct} renderClass The constructor function reference. Must have a "Render()" method.
	/// 
	/// "self" is available, with the following parameters too: _surface, _surfaceW, _surfaceH, _camX, _camY, _camW, _camH, _texMaterial, _texLightmap, _texEmissive
	static SetRenderClass = function(_renderClass) {
		if (_renderClass != undefined) {
			__deferredFunction = method(self, new _renderClass().Render);
		} else {
			__crystal_trace("Deferred class is undefined.", 1);
		}
	}
	
	/// @desc Toggle renderer rendering. If disabled, nothing will be rendered to the surfaces internally (including shadows), and GetRenderSurface() will return the input surface (e.g: application_surface).
	/// @method SetRenderEnable(enabled)
	/// @param {Bool} enabled Toggle rendering.
	/// @param {Bool} clearMemory If true and "enabled" is false, cleans all internal surfaces from VRAM.
	static SetRenderEnable = function(_enabled=-1, _clearMemory=true) {
		if (_enabled == -1) {
			__isRenderEnabled = !__isRenderEnabled;
		} else {
			__isRenderEnabled = _enabled;
		}
		if (!__isRenderEnabled && _clearMemory) {
			__cleanSurfaces();
		}
	}
	
	/// @desc Toggle renderer drawing. If disabled, the lighting system will not draw the final surface, but will still continue rendering.
	/// You MUST disable this if you are using post-processing, since it is the post-processing that must draw the final surface.
	/// @method SetDrawEnable(enabled)
	/// @param {Bool} enabled Toggle drawing.
	static SetDrawEnable = function(_enabled=-1) {
		if (_enabled == -1) {
			__isDrawEnabled = !__isDrawEnabled;
		} else {
			__isDrawEnabled = _enabled;
		}
	}
	#endregion
	
	#region GETTERS
	/// @desc Use this function to get the surface of some render pass.
	/// @method GetPassSurface(pass)
	/// @param {Enum.CRYSTAL_PASS} pass The pass you want to access to get the surface.
	static GetPassSurface = function(_pass) {
		return __renderPass[_pass].surface;
	}
	
	/// @desc Use this function to get the render resolution of some render pass. A value from 0 to 1.
	/// @method GetPassResolution(pass)
	/// @param {Enum.CRYSTAL_PASS} pass The pass you want to access to get the render resolution.
	static GetPassResolution = function(_pass) {
		return __renderPass[_pass].resolution;
	}
	
	/// @desc Gets the final surface of the lighting system. Useful for using this as input surface for post-processing.
	/// @method GetRenderSurface();
	static GetRenderSurface = function() {
		return __finalRenderSurf;
	}
	
	/// @desc Gets the overall render resolution. A value from 0 to 1.
	/// @method GetRenderResolution()
	static GetRenderResolution = function() {
		return __renderResolution;
	}
	
	/// @desc Gets the ambient color.
	/// @method GetAmbientColor()
	static GetAmbientColor = function() {
		return __ambientLightColor;
	}
	
	/// @desc Gets the ambient intensity. A value from 0 to 1.
	/// @method GetAmbientIntensity()
	static GetAmbientIntensity = function() {
		return __ambientLightIntensity;
	}
	
	/// @desc Gets the current ambient LUT texture.
	/// @method GetAmbientLUTTexture()
	static GetAmbientLUTTexture = function() {
		return __ambientLutTex;
	}
	
	/// @desc Gets the current Lights Blendmode.
	/// @method GetLightsBlendmode()
	static GetLightsBlendmode = function() {
		return __lightsBlendMode;
	}
	
	/// @desc Gets the current lights intensity.
	/// @method GetLightsIntensity()
	static GetLightsIntensity = function() {
		return __lightsIntensity;
	}
	
	/// @desc With this function you can get the light pixel color (in screen-space) at the selected position (in world-space). The color is not influenced by ambient light. 
	/// Useful for detecting collisions with lights and creating cool mechanics.
	/// @method GetLightsCollisionAt(xPosition, yPosition)
	/// @param {Real} xPosition The x position (in the room) to check for collision.
	/// @param {Real} yPosition The y position (in the room) to check for collision.
	static GetLightsCollisionAt = function(_xPosition, _yPosition) {
		if (__lightmapBuffer == undefined) return c_black;
		// TODO: world space to surface space
		var _NDC = matrix_transform_vertex(matrix_multiply(camera_get_view_mat(__sourceCamera), camera_get_proj_mat(__sourceCamera)), _xPosition, _yPosition, 0);
		var _x = floor((_NDC[0]*0.5+0.5) * __lightmapSurfaceWidth);
		var _y = floor((-_NDC[1]*0.5+0.5) * __lightmapSurfaceHeight);
		_x = clamp(_x, 0, __lightmapSurfaceWidth-1);
		_y = clamp(_y, 0, __lightmapSurfaceHeight-1);
		var _bytesPerPixel = __lightmapBytesPerPixel;
		var _position = (_x + _y * __lightmapSurfaceWidth) * _bytesPerPixel;
		var _r = 0, _g = 0, _b = 0, _a = 0;
		// 8 bits
		if (_bytesPerPixel == 4) {
			var _pixel = buffer_peek(__lightmapBuffer, _position, buffer_u32); // get ABGR
			_r = (_pixel) & 0xFF;
			_g = (_pixel >> 8) & 0xFF;
			_b = (_pixel >> 16) & 0xFF;
			//_a = (_pixel >> 24) & 0xFF;
		} else
		// 16 bits
		if (_bytesPerPixel == 8) {
			_r = round(clamp(buffer_peek(__lightmapBuffer, _position, buffer_f16), 0, 1) * 255);
			_g = round(clamp(buffer_peek(__lightmapBuffer, _position + 2, buffer_f16), 0, 1) * 255);
			_b = round(clamp(buffer_peek(__lightmapBuffer, _position + 4, buffer_f16), 0, 1) * 255);
			//_a = buffer_peek(__lightmapBuffer, _position + 6, buffer_f16);
		} else
		// 32 bits
		if (_bytesPerPixel == 16) {
			_r = round(clamp(buffer_peek(__lightmapBuffer, _position, buffer_f16), 0, 1) * 255);
			_g = round(clamp(buffer_peek(__lightmapBuffer, _position + 4, buffer_f16), 0, 1) * 255);
			_b = round(clamp(buffer_peek(__lightmapBuffer, _position + 8, buffer_f16), 0, 1) * 255);
			//_a = buffer_peek(__lightmapBuffer, _position + 12, buffer_f16);
		}
		return (_b << 16) | (_g << 8) | _r;
	}
	
	/// @desc Returns if Materials are enabled.
	/// @method IsMaterialsEnabled()
	static IsMaterialsEnabled = function() {
		return __isMaterialsEnabled;
	}
	
	/// @desc Returns if HDR is enabled.
	/// @method IsHDREnabled()
	static IsHDREnabled = function() {
		return __isHDREnabled;
	}
	
	/// @desc Returns if HDR Lightmap is enabled.
	/// @method IsHDRLightmapEnabled()
	static IsHDRLightmapEnabled = function() {
		return __isHDRLightmapEnabled;
	}
	
	/// @desc Returns if Culling is enabled.
	/// @method IsCullingEnabled()
	static IsCullingEnabled = function() {
		return __isCullingEnabled;
	}
	
	/// @desc Returns if Dithering is enabled.
	/// @method IsDitheringEnabled()
	static IsDitheringEnabled = function() {
		return __isDitheringEnabled;
	}
	
	/// @desc Returns if lights collision generation is enabled.
	/// @method IsLightsCollisionEnabled()
	static IsLightsCollisionEnabled = function() {
		return __isGeneratingLightsCollision;
	}
	#endregion
	
	#region RENDER
	
	/// @desc This function MUST be executed exclusively in the Begin Step event. Because of the internal GameMaker execution order, some things may not work correctly outside of this event.
	// This function just resets some renderer variables. It doesn't do anything else.
	/// @method PreRender()
	static PreRender = function() {
		__preRenderUndefined = false;
		if (event_number != ev_step_begin) {
			__crystal_trace("PreRender() is running outside of Begin Step event", 1);
		}
		// clear renderables list from all Render Passes each frame
		var i = 0;
		repeat(__renderPassAmount) {
			ds_list_clear(__renderPass[i++].renderables);
		}
	}
	
	/// @desc Renderize lights, shadows, materials and other things on the internal surface, which is a copy from the input surface. It should be executed after the Draw event, like "Draw End" (recommended).
	/// @method Render(surface, camera)
	/// @param {Id.Surface} surface The input surface to renderize from (example: application_surface).
	/// @param {Id.Camera} camera The camera pointing the place in world to render from.
	static Render = function(_surface, _camera) {
		#region Checks
		if (!view_enabled && _camera == undefined) {
			if (__allowRendering) {
				__allowRendering = false;
				__crystal_trace("ERROR: You must enable viewports and use a camera to render!", 1);
			}
			exit;
		}
		if (!surface_exists(_surface)) {
			if (__allowRendering) {
				__allowRendering = false;
				__crystal_trace("WARNING: trying to renderize using non-existent surface", 2);
			}
			exit;
		}
		if (__preRenderUndefined) {
			if (__allowRendering) {
				__allowRendering = false;
				__crystal_trace("ERROR: PreRender() is not being called, unable to work correctly!", 1);
			}
			exit;
		}
		#endregion
		__allowRendering = true;
		__sourceSurface = _surface;
		__sourceCamera = _camera;
		
		// Render Everything
		if (__isRenderEnabled) {
			// if different resolution, delete stuff to be updated
			var _surfaceWidth = surface_get_width(_surface), _surfaceHeight = surface_get_height(_surface);
			if (_surfaceWidth != __renderSurfaceOldWidth || _surfaceHeight != __renderSurfaceOldHeight) {
				__cleanSurfaces();
				__renderSurfaceWidth = _surfaceWidth * __renderResolution;
				__renderSurfaceHeight = _surfaceHeight * __renderResolution;
				__renderSurfaceWidth -= frac(__renderSurfaceWidth);
				__renderSurfaceHeight -= frac(__renderSurfaceHeight);
				__renderSurfaceOldWidth = _surfaceWidth;
				__renderSurfaceOldHeight = _surfaceHeight;
			}
			var _surfaceW = __renderSurfaceWidth,
			_surfaceH = __renderSurfaceHeight,
			_pass = undefined,
			_currentFrameTime = get_timer();
			
			// =================================
			// Get camera properties
			#region Get Camera Properties
				// Get position, size and rotation from camera view/projection matrix
				// Useful for drawing quads at camera position and rotation
				var
				_viewMat = camera_get_view_mat(_camera),
				_projMat = camera_get_proj_mat(_camera),
				_viewX = -_viewMat[12],
				_viewY = -_viewMat[13],
				_viewW = round(abs(2/_projMat[0])),
				_viewH = round(abs(2/_projMat[5])),
				_camCos = _viewMat[0], // yUp
				_camSin = _viewMat[1], // xUp
				_camAngle = darctan2(_camSin, _camCos),
				_camCenterX = _viewX*_camCos + _viewY*_camSin,
				_camCenterY = -_viewX*_camSin + _viewY*_camCos,
				_camX = _viewX - _viewW/2,
				_camY = _viewY - _viewH/2,
				_camW = _viewW,
				_camH = _viewH,
				_quadXscale = (_camW+1) * 0.5,
				_quadYscale = (_camH+1) * 0.5;
				
				// Create temporary orthographic camera to draw surfaces on the screen
				if (__surfaceCamera == -1) {
					__surfaceCamera = camera_create_view(0, 0, _surfaceW, _surfaceH);
				} else {
					camera_set_view_size(__surfaceCamera, _surfaceW, _surfaceH);
				}
			#endregion
			
			
			// Culling (Lights, Materials and Shadows)
			#region Culling
			if (__isCullingEnabled) {
				// TO-DO: use some kind of quadtree.
				// Update DYNAMIC STUFF only when camera moves a distance or when zooming
				if (point_distance(_camCenterX, _camCenterY, __cullingDynamicsOldCamX, __cullingDynamicsOldCamY) > __cullingDynamicsViewMoveDistance || _camW != __cullingDynamicsOldCamW || _camH != __cullingDynamicsOldCamH || __cullingDynamicsUpdateNow) {
					__cullingDynamicsUpdateNow = false;
					__cullingDynamicsOldCamX = _camCenterX;
					__cullingDynamicsOldCamY = _camCenterY;
					__cullingDynamicsOldCamW = _camW;
					__cullingDynamicsOldCamH = _camH;
					
					// disable stuff outside view
					var
					dssize = ds_list_size(__dynamicShadowsArray),
					m1size = ds_list_size(__matNormalSprites),
					m2size = ds_list_size(__matEmissiveSprites),
					m3size = ds_list_size(__matReflectionSprites),
					m4size = ds_list_size(__matMetallicSprites),
					m5size = ds_list_size(__matRoughnessSprites),
					m6size = ds_list_size(__matAoSprites),
					m7size = ds_list_size(__matMaskSprites);
					instance_activate_object(__cle_objLightDynamic); // activate all dynamic lights
					// all dynamic shadows, materials and lights (static lights should NOT be disable outside of camera! - for visual reasons)
					if (CLE_CFG_CAMERA_ROTATION) {
						var _cullSize = min(_camW, _camH) + __cullingDynamicsViewBorderSize / 2;
						with(__cle_objLightDynamic) {if (point_distance(x, y, _camCenterX, _camCenterY) > _cullSize) instance_deactivate_object(id);}
						var k = 0;
						repeat(dssize) {with(__dynamicShadowsArray[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m1size) {with(__matNormalSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m2size) {with(__matEmissiveSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m3size) {with(__matReflectionSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m4size) {with(__matMetallicSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m5size) {with(__matRoughnessSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m6size) {with(__matAoSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
						k = 0;
						repeat(m7size) {with(__matMaskSprites[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
					} else {
						var
						_cX1 = _camX-__cullingDynamicsViewBorderSize, _cY1 = _camY-__cullingDynamicsViewBorderSize,
						_cX2 = _camX+_camW+__cullingDynamicsViewBorderSize, _cY2 = _camY+_camH+__cullingDynamicsViewBorderSize;
						with(__cle_objLightDynamic) {if (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2)) instance_deactivate_object(id);}
						var k = 0;
						repeat(dssize) {with(__dynamicShadowsArray[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m1size) {with(__matNormalSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m2size) {with(__matEmissiveSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m3size) {with(__matReflectionSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m4size) {with(__matMetallicSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m5size) {with(__matRoughnessSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m6size) {with(__matAoSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
						k = 0;
						repeat(m7size) {with(__matMaskSprites[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
					}
				} else {
					__cullingDynamicsAutoUpdateTimer -= 1;
					if (__cullingDynamicsAutoUpdateTimer <= 0) {
						__cullingDynamicsAutoUpdateTimer = __cullingDynamicsAutoUpdateTimerBase;
						__cullingDynamicsUpdateNow = true;
					}
				}
				
				// Update STATIC STUFF only when camera moves a distance
				if (point_distance(_camCenterX, _camCenterY, __cullingStaticsOldCamX, __cullingStaticsOldCamY) > __cullingStaticsViewMoveDistance) {
					__cullingStaticsOldCamX = _camCenterX;
					__cullingStaticsOldCamY = _camCenterY;
					__vbuffStaticRebuild = true; // enable static shadows update
					
					// disable stuff outside view
					var sssize = ds_list_size(__staticShadowsArray);
					// all static shadows
					if (CLE_CFG_CAMERA_ROTATION) {
						var _cullSize = min(_camW, _camH) + __cullingStaticsViewBorderSize / 2;
						var k = 0;
						repeat(sssize) {with(__staticShadowsArray[| k++]) {__cull = point_distance(x, y, _camCenterX, _camCenterY) > _cullSize;}}
					} else {
						var
						_cX1 = _camX-__cullingStaticsViewBorderSize, _cY1 = _camY-__cullingStaticsViewBorderSize,
						_cX2 = _camX+_camW+__cullingStaticsViewBorderSize, _cY2 = _camY+_camH+__cullingStaticsViewBorderSize;
						var k = 0;
						repeat(sssize) {with(__staticShadowsArray[| k++]) {__cull = (( x < _cX1 || x > _cX2) || (y < _cY1 || y > _cY2));}}
					}
				}
			}
			#endregion
			
			
			// Shadows vertex generation
			#region Shadows Vertex Buffers
				var _vertexShadowFormat = __shadowVertexFormat;
				
				#region Build Static Shadows
					var _staticVbuff = __vbuffStatic;
					var _array = __staticShadowsArray;
					// rebuild static shadows if required
					if (__vbuffStaticRebuild) {
						if (__vbuffStatic != undefined) {
							vertex_delete_buffer(__vbuffStatic);
							__vbuffStatic = undefined;
						}
						__vbuffStaticRebuild = false;
					}
					// build static shadows
					if (__vbuffStatic == undefined) {
						__vbuffStatic = vertex_create_buffer();
						_staticVbuff  = __vbuffStatic;
						vertex_begin(__vbuffStatic, _vertexShadowFormat);
						// add vertices (shadows) to the buffer
						var i = 0, isize = ds_list_size(_array); // using ds_list for performance...
						repeat(isize) {
							with(_array[| i]) {
								// destroy
								if (__destroyed) {
									ds_list_delete(_array, i);
								} else {
									// add vertices from shadow points
									if (enabled && !__cull) {
										__mode(_staticVbuff);
									}
									++i;
								}
							}
						}
						vertex_end(__vbuffStatic);
						// freeze vertex buffer to improve performance
						if (vertex_get_number(__vbuffStatic) > 0) vertex_freeze(__vbuffStatic);
					}
				#endregion
				
				#region Build Dynamic Shadows
					if (__vbuffDynamic == undefined) {
						__vbuffDynamic = vertex_create_buffer();
					}
					var _dynamicVbuff = __vbuffDynamic;
					var _array = __dynamicShadowsArray;
					vertex_begin(__vbuffDynamic, _vertexShadowFormat);
					// add vertices (shadows) to the buffer
					var i = 0, isize = ds_list_size(_array);
					repeat(isize) {
						with(_array[| i]) {
							// destroy
							if (__destroyed) {
								ds_list_delete(_array, i);
							} else {
								// add vertices from shadow points
								if (enabled && !__cull) {
									__mode(_dynamicVbuff);
								}
								++i;
							}
						}
					}
					vertex_end(__vbuffDynamic);
				#endregion
			
			#endregion
			
			
			// Define default textures
			#region Default Textures
				// default light shader textures
				var _texAlbedo = surface_get_texture(_surface),
					_texLightmap = __textureBlack,
					_texNormalMap = __textureNormal,
					_texMaterial = __textureMaterial,
					_texEmissive = __textureBlack,
					_texReflections = __textureWhite;
			#endregion
			
			
			// Render Materials (Normal Maps, Emission, Ambient Occlusion, Roughness, Metallic and Reflections)
			#region Render Material Surfaces
				// surfaces
				if (__isMaterialsEnabled) {
					#region >> Normal maps
					_pass = __renderPass[CRYSTAL_PASS.NORMALS];
					
					static _normal_u_angle = shader_get_uniform(__cle_shNormal, "u_angle");
					static _normal_u_scale = shader_get_uniform(__cle_shNormal, "u_scale");
					
					var _layersArray = __matNormalLayers,
						_layersAmount = ds_list_size(_layersArray),
						_spritesArray = __matNormalSprites,
						_spritesAmount = ds_list_size(_spritesArray),
						_renderablesList = _pass.renderables,
						_renderablesAmount = ds_list_size(_renderablesList);
					
					if (_layersAmount > 0 || _spritesAmount > 0 || _renderablesAmount > 0) {
						if (!surface_exists(_pass.surface)) {
							_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, surface_rgba8unorm);
							__normalmapSurfaceTex = surface_get_texture(_pass.surface);
						}
						gpu_push_state();
						gpu_set_zwriteenable(false);
						surface_set_target(_pass.surface, _surface);
							// since this is the base normal surface, alpha must be 1
							draw_clear_ext(make_color_rgb(128, 128, 255), 1);
							// NormalMap shader applies to Layers + Sprites + Renderables
							shader_set(__cle_shNormal);
							//gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha); // NOT NEEDED
							
							#region Layers (surfaces)
								if (_layersAmount > 0) {
									// apply ortho camera
									camera_apply(__surfaceCamera);
									// render
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_layersAmount) {
										with(_layersArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_layersArray, i);
											} else {
												// draw normal surfaces
												if (__isRenderEnabled && surface_exists(__surface)) {
													// The effect will usually replace the shader, so it is expected that you will need to repeat the original shader code
													gpu_set_depth(depth); // change the depth of the surface (containing the layers that are rendering inside...)
													if (__layerEffect == undefined) {
														shader_set_uniform_f(_normal_u_angle, 0); // reset angle to 0
														shader_set_uniform_f(_normal_u_scale, 1, 1); // reset scale to 1
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													} else {
														var _curShader = shader_current();
														__layerEffect.Begin(_camW, _camH);
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH); // will be drawn only on normals... the original surface is intact
														__layerEffect.End();
														shader_set(_curShader);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							camera_apply(_camera);
							
							#region Sprites
								if (_spritesAmount > 0) {
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_spritesAmount) {
										with(_spritesArray[| i]) { // with material!!!
											// destroy
											if (__destroyed) {
												ds_list_delete(_spritesArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && normalSprite != undefined) {
													gpu_set_depth(depth);
													shader_set_uniform_f(_normal_u_angle, angle);
													shader_set_uniform_f(_normal_u_scale, xScale, yScale);
													if (isBitmap) {
														draw_sprite_ext(normalSprite, normalSpriteSubimg, x, y, xScale, yScale, angle, c_white, normalIntensity);
													} else {
														draw_skeleton_time(normalSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, normalIntensity);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							#region Renderables
								if (_renderablesAmount > 0) {
									shader_set_uniform_f(_normal_u_angle, 0); // reset params before drawing!
									shader_set_uniform_f(_normal_u_scale, 1, 1);
									var i = 0;
									repeat(_renderablesAmount) {
										_renderablesList[| i++](self);
									}
								}
							#endregion
							
							shader_reset();
						surface_reset_target();
						gpu_pop_state();
						_texNormalMap = __normalmapSurfaceTex;
					} else {
						// free surface if it existed before, since we are not using it
						if (surface_exists(_pass.surface)) {
							surface_free(_pass.surface);
							__normalmapSurfaceTex = -1;
						}
					}
					#endregion
					
					#region >> Material: Metallic (R) + Roughness (G) + Ambient Occlusion (B) + Mask (A)  >> A MASK DEVERIA SER O RIM LIGHTING!!
					_pass = __renderPass[CRYSTAL_PASS.MATERIAL];
					
					var _layersArray = __matMaterialLayers,
						_metallicArray = __matMetallicSprites,
						_roughnessArray = __matRoughnessSprites,
						_aoSpritesArray = __matAoSprites,
						_maskSpritesArray = __matMaskSprites,
						_renderablesList = _pass.renderables,
						
						_layersAmount = ds_list_size(_layersArray),
						_metallicSpritesAmount = ds_list_size(_metallicArray),
						_roughnessSpritesAmount = ds_list_size(_roughnessArray),
						_aoSpritesAmount = ds_list_size(_aoSpritesArray),
						_maskSpritesAmount = ds_list_size(_maskSpritesArray),
						_renderablesAmount = ds_list_size(_renderablesList);
					
					if (_layersAmount > 0 || _metallicSpritesAmount > 0 || _roughnessSpritesAmount > 0 || _aoSpritesAmount > 0 || _maskSpritesAmount > 0 || _renderablesAmount > 0) {
						if (!surface_exists(_pass.surface)) {
							_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, surface_rgba8unorm);
							__materialSurfaceTex = surface_get_texture(_pass.surface);
						}
						gpu_push_state();
						gpu_set_zwriteenable(false);
						surface_set_target(_pass.surface, _surface);
							var _oldDepth = gpu_get_depth(), _oldZtest = gpu_get_ztestenable();
							draw_clear_ext(c_black, 1); // must be 0, because of Mask
							
							// apply ortho camera
							camera_apply(__surfaceCamera);
							
							// clear ambient occlusion to white (draw white quad before every ambient occlusion)
							gpu_set_ztestenable(false);
							gpu_set_colorwriteenable(false, false, true, false); // draw to AO only
							draw_sprite_stretched_ext(__cle_sprPixel, 0, 0, 0, _surfaceW, _surfaceH, c_white, 1); // without rotation
							gpu_set_colorwriteenable(true, true, true, true);
							gpu_set_ztestenable(_oldZtest);
							
							// draw different materials in different channels
							//gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
							
							#region Layers (surfaces)
								if (_layersAmount > 0) {
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_layersAmount) {
										with(_layersArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_layersArray, i);
											} else {
												// draw material surface
												if (__isRenderEnabled && surface_exists(__surface)) {
													// The effect will usually replace the shader, so it is expected that you will need to repeat the original shader code
													gpu_set_depth(depth);
													if (__layerEffect == undefined) {
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													} else {
														var _curShader = shader_current();
														__layerEffect.Begin();
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
														__layerEffect.End();
														shader_set(_curShader);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							camera_apply(_camera);
							
							#region Sprites
								var _oldColorWrite = gpu_get_colorwriteenable();
								
								// Metallic (R)
								if (_metallicSpritesAmount > 0) {
									gpu_set_colorwriteenable(true, false, false, false);
									
									var i = 0;
									repeat(_metallicSpritesAmount) {
										with(_metallicArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_metallicArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && metallicSprite != undefined) {
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(metallicSprite, metallicSpriteSubimg, x, y, xScale, yScale, angle, c_white, metallicIntensity);
													} else {
														draw_skeleton_time(metallicSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, metallicIntensity);
													}
												}
												++i;
											}
										}
									}
								}
								
								// Roughness (G)
								if (_roughnessSpritesAmount > 0) {
									gpu_set_colorwriteenable(false, true, false, false);
									var i = 0;
									repeat(_roughnessSpritesAmount) {
										with(_roughnessArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_roughnessArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && roughnessSprite != undefined) {
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(roughnessSprite, roughnessSpriteSubimg, x, y, xScale, yScale, angle, c_white, roughnessIntensity);
													} else {
														draw_skeleton_time(roughnessSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, roughnessIntensity);
													}
												}
												++i;
											}
										}
									}
								}
								
								// Ambient Occlusion (B)
								if (_aoSpritesAmount > 0) {
									gpu_set_colorwriteenable(false, false, true, false);
									var i = 0;
									repeat(_aoSpritesAmount) {
										with(_aoSpritesArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_aoSpritesArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && aoSprite != undefined) {
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(aoSprite, aoSpriteSubimg, x, y, xScale, yScale, angle, c_white, aoIntensity);
													} else {
														draw_skeleton_time(aoSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, aoIntensity);
													}
												}
												++i;
											}
										}
									}
								}
								
								// Mask (A) - WIP
								/*if (_maskSpritesAmount > 0) {
									gpu_set_colorwriteenable(false, false, false, true);
									shader_set(__cle_shWriteToAlpha);
									var i = 0;
									repeat(_maskSpritesAmount) {
										with(_maskSpritesArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_maskSpritesArray, i);
											} else {
												// draw sprite
												if (active && !__cull && maskSprite != undefined) {
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(maskSprite, maskSpriteSubimg, x, y, xScale, yScale, angle, c_white, maskIntensity);
													} else {
														draw_skeleton_time(maskSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, maskIntensity);
													}
												}
												++i;
											}
										}
									}
									shader_reset();
								}*/
								
								// reset
								gpu_set_colorwriteenable(_oldColorWrite);
							#endregion
							
							gpu_set_depth(_oldDepth);
							
							#region Renderables
								if (_renderablesAmount > 0) {
									gpu_set_blendmode(bm_normal);
									i = 0;
									repeat(_renderablesAmount) {
										_renderablesList[| i++](self);
									}
								}
							#endregion
							
						surface_reset_target();
						gpu_pop_state();
						_texMaterial = __materialSurfaceTex; // override
					} else {
						// free surface if it existed before, since we are not using it
						if (surface_exists(_pass.surface)) {
							surface_free(_pass.surface);
							__materialSurfaceTex = -1;
						}
					}
					
					#endregion
					
					#region >> Emissive
					_pass = __renderPass[CRYSTAL_PASS.EMISSIVE];
					
					static _emission_u_intensity = shader_get_uniform(__cle_shEmission, "u_emission");
					var _layersArray = __matEmissiveLayers,
						_spritesArray = __matEmissiveSprites,
						_renderablesList = _pass.renderables,
						_layersAmount = ds_list_size(_layersArray),
						_spritesAmount = ds_list_size(_spritesArray),
						_renderablesAmount = ds_list_size(_renderablesList);
					
					if (_layersAmount > 0 || _spritesAmount > 0 || _renderablesAmount > 0) {
						if (!surface_exists(_pass.surface)) {
							_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, __surfaceFormat);
							__emissiveSurfaceTex = surface_get_texture(_pass.surface);
						}
						gpu_push_state();
						gpu_set_zwriteenable(false);
						surface_set_target(_pass.surface, _surface);
							draw_clear_ext(c_black, 1); // full black alpha 1, because it's emissive
							shader_set(__cle_shEmission);
							//gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
							// Emission shader applies to: Layers + Sprites + Renderables
							// you may want to use mat_emission_set_intensity()
							
							#region Layers (surfaces)
								if (_layersAmount > 0) {
									// apply ortho camera
									camera_apply(__surfaceCamera);
									// render
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_layersAmount) {
										with(_layersArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_layersArray, i);
											} else {
												// draw normal surfaces
												if (__isRenderEnabled && surface_exists(__surface)) {
													// The effect will usually replace the shader, so it is expected that you will need to repeat the original shader code
													shader_set_uniform_f(_emission_u_intensity, max(emissionIntensity, 0));
													gpu_set_depth(depth);
													if (__layerEffect == undefined) {
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													} else {
														var _curShader = shader_current();
														__layerEffect.Begin();
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
														__layerEffect.End();
														shader_set(_curShader);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}	
							#endregion
							
							camera_apply(_camera);
							
							#region Sprites
								if (_spritesAmount > 0) {
									var _oldDepth = gpu_get_depth();
									i = 0;
									repeat(_spritesAmount) {
										with(_spritesArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_spritesArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && emissiveSprite != undefined) {
													shader_set_uniform_f(_emission_u_intensity, max(emissionIntensity, 0));
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(emissiveSprite, emissiveSpriteSubimg, x, y, xScale, yScale, angle, emissionColor, 1);
													} else {
														draw_skeleton_time(emissiveSprite, animName, skinName, animTime, x, y, xScale, yScale, angle, c_white, 1);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							#region Renderables
								if (_renderablesAmount > 0) {
									gpu_set_blendmode(bm_normal);
									i = 0;
									repeat(_renderablesAmount) {
										_renderablesList[| i++](self);
									}
								}
							#endregion
							
							shader_reset();
						surface_reset_target();
						gpu_pop_state();
						_texEmissive = __emissiveSurfaceTex; // override
					} else {
						// free surface if it existed before, since we are not using it
						if (surface_exists(_pass.surface)) {
							surface_free(_pass.surface);
							__emissiveSurfaceTex = -1;
						}
					}
					
					#endregion
					
					#region >> Reflections
					_pass = __renderPass[CRYSTAL_PASS.REFLECTIONS];
					
					var _layersArray = __matReflectionLayers,
						_spritesArray = __matReflectionSprites,
						_renderablesList = _pass.renderables,
						_layersAmount = ds_list_size(_layersArray),
						_spritesAmount = ds_list_size(_spritesArray),
						_renderablesAmount = ds_list_size(_renderablesList);
					
					if (_layersAmount > 0 || _spritesAmount > 0 || _renderablesAmount > 0 || __isSSREnabled) {
						if (!surface_exists(_pass.surface)) {
							_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, surface_rgba8unorm);
							__reflectionsSurfaceTex = surface_get_texture(_pass.surface);
						}
						gpu_push_state();
						gpu_set_zwriteenable(false);
						surface_set_target(_pass.surface, _surface);
							draw_clear_ext(c_white, 1);
							gpu_set_colorwriteenable(true, true, true, false);
							// No shader is being applied here...
							
							// apply ortho camera
							camera_apply(__surfaceCamera);
							
							// SSR (screen-space reflection)
							if (__isSSREnabled) {
								if (__ssrAlpha > 0) draw_surface_stretched_ext(_surface, 0, 0, _surfaceW, _surfaceH, c_white, __ssrAlpha);
								if (__ssrSky != -1) {
									if (__ssrSkyAlpha > 0) {
										//if (CLE_CFG_CAMERA_ROTATION) { // Doesn't look good/not recommended. But it works for rotated cameras. Should be inside the brackets below.
											//var _oldMatrix = matrix_get(matrix_world), _xOffset = _surfaceW/2, _yOffset = _surfaceH/2;
											//matrix_set(matrix_world, matrix_build(_xOffset, _yOffset, 0, 0, 0, -_camAngle, 1, 1, 1));
											//draw_sprite_stretched_ext(__ssrSprite, __ssrSpriteSubimg, -_xOffset, -_yOffset, _surfaceW, _surfaceH, c_white, __ssrSpriteAlpha);
											//matrix_set(matrix_world, _oldMatrix);
										//}
										if (sprite_exists(__ssrSky)) {
											draw_sprite_stretched_ext(__ssrSky, __ssrSkySubimg, 0, 0, _surfaceW, _surfaceH, __ssrSkyColor, __ssrSkyAlpha);
										} else
										if (surface_exists(__ssrSky)) {
											draw_surface_stretched_ext(__ssrSky, 0, 0, _surfaceW, _surfaceH, __ssrSkyColor, __ssrSkyAlpha);
										}
									}
								}
							}
							
							#region Layers (surfaces)
								if (_layersAmount > 0) {
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_layersAmount) {
										with(_layersArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_layersArray, i);
											} else {
												// draw normal surfaces
												if (__isRenderEnabled && surface_exists(__surface)) {
													gpu_set_depth(depth);
													if (__layerEffect == undefined) {
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													} else {
														__layerEffect.Begin();
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
														__layerEffect.End();
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							camera_apply(_camera);
							
							#region Sprites
								if (_spritesAmount > 0) {
									var _oldDepth = gpu_get_depth();
									i = 0;
									repeat(_spritesAmount) {
										with(_spritesArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_spritesArray, i);
											} else {
												// draw sprite
												if (enabled && !__cull && reflectionSprite != undefined) {
													gpu_set_depth(depth);
													if (isBitmap) {
														draw_sprite_ext(reflectionSprite, reflectionSpriteSubimg, x, y, xScale*reflectionXscale, yScale*reflectionYscale, angle, reflectionColor, reflectionIntensity);
													} else {
														draw_skeleton_time(reflectionSprite, animName, skinName, animTime, x, y, xScale*reflectionXscale, yScale*reflectionYscale, angle, c_white, reflectionIntensity);
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							#region Renderables
								if (_renderablesAmount > 0) {
									gpu_set_blendmode(bm_normal);
									i = 0;
									repeat(_renderablesAmount) {
										_renderablesList[| i++](self);
									}
								}
							#endregion
							
						surface_reset_target();
						gpu_pop_state();
						_texReflections = __reflectionsSurfaceTex; // override
					} else {
						// free surface if it existed before, since we are not using it
						if (surface_exists(_pass.surface)) {
							surface_free(_pass.surface);
							__reflectionsSurfaceTex = -1;
						}
					}
					
					#endregion
				}
			#endregion
			
			
			// Render Lights and Shadows
			#region Render Lights and Shadows
				_pass = __renderPass[CRYSTAL_PASS.LIGHT];
				
				// Only if intensity is not 0
				if (__lightsIntensity > 0) {
					// recreate surface and buffer when necessary
					if (!surface_exists(_pass.surface)) {
						_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, __isHDRLightmapEnabled ? __surfaceFormat : surface_rgba8unorm);
						__lightmapSurfaceTex = surface_get_texture(_pass.surface);
						if (__lightmapBuffer != undefined) {
							buffer_delete(__lightmapBuffer);
							__lightmapBuffer = undefined;
						}
					}
					surface_set_target(_pass.surface, _surface);
						draw_clear_ext(c_black, 0); // alpha MUST be 0 (because of shadows)
						gpu_push_state(); // >>>>>>>>
						gpu_set_zwriteenable(false);
						gpu_set_alphatestenable(false); // alpha test its not necessary for lights, since the surface is black and additive
						gpu_set_sprite_cull(!__isCullingEnabled); // do not cull sprites if we're already doing it
						gpu_set_cullmode(cull_counterclockwise);
						var _oldDepth = gpu_get_depth();
						var _oldMatrix = matrix_get(matrix_world);
						
						#region Shared Uniforms + Blendmodes
							// Shadows
							static _u_shadowParams = shader_get_uniform(__cle_shVertShadow, "u_params"); // shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset
							static _u_shadowParams2 = shader_get_uniform(__cle_shVertShadow, "u_params2"); // 2d light position, lightPenetration
							static _u_dirShadowParams = shader_get_uniform(__cle_shVertDirShadow, "u_params"); // depth, length, penumbra, angle
							static _u_dirShadowParams2 = shader_get_uniform(__cle_shVertDirShadow, "u_params2"); // xDir, yDir
							// Blend modes
							// These are the best blend modes for a lighting system and it works with HDR (since shadows are cumulative)
							// To work correctly, the backbuffer needs to have alpha 0, as the light will be multiplied by the inverse: 1-destAlpha (1)
							static _shadowsBlendMode = [bm_zero, bm_one, bm_inv_dest_alpha, bm_one]; // vec4 finalColor = vec4(destRGB, srcAlpha*(1.0-destAlpha)+destAlpha);
							static _lightsBlendMode = [bm_inv_dest_alpha, bm_one, bm_zero, bm_zero]; // vec4 finalColor = vec4(srcRGB*(1.0-destAlpha)+destRGB, destAlpha);
						#endregion
						
						#region Stencil Mask (TO-DO)
							// ENABLE STENCIL TEST (o stencil buffer sempre existe quando a surface tem depth)
							/*gpu_set_stencil_enable(true);
							
							// desenhar local onde as luzes vão ser cortadas e desenhadas dentro: deve ser no formato da layer, por exemplo (desenhar a layer aqui...)
							draw_clear_stencil(0); // resetar números da surface para 0
							gpu_set_stencil_func(cmpfunc_always);
							gpu_set_stencil_pass(stencilop_replace);
							gpu_set_stencil_ref(10);
							gpu_set_alphatestenable(true); // é necessário para cortar os pixels...
							gpu_set_depth(-15000);
							
							var _surff = __renderPass[CRYSTAL_PASS.MATERIAL].surface;
							//shader_set(__cle_shMaskRGB);
							//texture_set_stage(shader_get_sampler_index(__cle_shMaskRGB, "u_materialTex"), surface_get_texture(_surff));
							//draw_sprite_stretched_ext(__cle_sprWhite, 0, _camX, _camY, _camW, _camH, c_black, 1);
							//shader_reset();
							
							gpu_set_colorwriteenable(false, false, false, true);
							draw_surface_stretched_ext(_surff, _camX, _camY, _camW, _camH, c_black, 1);
							gpu_set_colorwriteenable(true, true, true, true);
							
							//draw_circle_color(mouse_x, mouse_y, 128, 0, 0, false);
							//draw_sprite(Sprite95_1, 0, mouse_x, mouse_y);
							
							
							// AO DESENHAR AS LUZES, MANTER OS PIXELS DENTRO DA MASK
							gpu_set_stencil_func(cmpfunc_equal);
							gpu_set_stencil_pass(stencilop_keep);
							
							gpu_set_stencil_ref(10); // poderia ser setado por luz!
							gpu_set_alphatestenable(false);*/
						#endregion
						
						#region Layers (surfaces)
							var _layersArray = __matLightLayers;
							var _layersAmount = ds_list_size(_layersArray);
							if (_layersAmount > 0) {
								// additive (like lights)
								gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
								// apply ortho camera
								camera_apply(__surfaceCamera);
								// render
								var _oldDepth = gpu_get_depth();
								var i = 0;
								shader_set(__cle_shEmission);
								repeat(_layersAmount) {
									with(_layersArray[| i]) {
										// destroy
										if (__destroyed) {
											ds_list_delete(_layersArray, i);
										} else {
											// draw normal surfaces
											if (__isRenderEnabled && surface_exists(__surface)) {
												shader_set_uniform_f(_emission_u_intensity, max(emissionIntensity, 0));
												gpu_set_depth(depth);
												if (__layerEffect == undefined) {
													draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
												} else {
													__layerEffect.Begin();
													draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													__layerEffect.End();
												}
											}
											++i;
										}
									}
								}
								// no need to reset shader, since the lights below will use shader_set too
							}
						#endregion
						
						camera_apply(_camera);
						
						// Accumulate additive lights
						// each light sets their own depth
						
						#region >> GI (Global Illumination)
							// < Radiance Cascades not implemented (no big plans yet...) >
							// this should naturally work with normal maps and materials
						#endregion
						
						#region >> Directional/Sun Lights
							#region uniforms + shaders
								static _u_dirLight_params = shader_get_uniform(__cle_shDirectLight, "u_params");
								
								static _u_dirLightPhong_normalTex = shader_get_sampler_index(__cle_shDirectLightPhong, "u_normalTex");
								static _u_dirLightPhong_materialTex = shader_get_sampler_index(__cle_shDirectLightPhong, "u_materialTex");
								static _u_dirLightPhong_params = shader_get_uniform(__cle_shDirectLightPhong, "u_params"); // directionXY, intensity
								static _u_dirLightPhong_params1 = shader_get_uniform(__cle_shDirectLightPhong, "u_params1"); // normalDistance, diffuse, specular
								
								static _u_dirLightBRDF_normalTex = shader_get_sampler_index(__cle_shDirectLightBRDF, "u_normalTex");
								static _u_dirLightBRDF_materialTex = shader_get_sampler_index(__cle_shDirectLightBRDF, "u_materialTex");
								static _u_dirLightBRDF_albedoTex = shader_get_sampler_index(__cle_shDirectLightBRDF, "u_albedoTex");
								static _u_dirLightBRDF_reflectionTex = shader_get_sampler_index(__cle_shDirectLightBRDF, "u_reflectionTex");
								static _u_dirLightBRDF_params = shader_get_uniform(__cle_shDirectLightBRDF, "u_params"); // directionXY, intensity
								static _u_dirLightBRDF_params1 = shader_get_uniform(__cle_shDirectLightBRDF, "u_params1"); // normalDistance, diffuse, specular, reflection
							#endregion
							
							// for each direct light (shadow draw + light quad draw)
							with(__cle_objDirectLight) {
								if (!enabled) continue;
								
								// shadow
								if (castShadows) {
									gpu_set_blendmode_ext_sepalpha(_shadowsBlendMode);
									gpu_set_zfunc(shadowLitType);
									gpu_set_cullmode(selfShadows ? cull_noculling : cull_counterclockwise);
									shader_set(__cle_shVertDirShadow);
									shader_set_uniform_f(_u_dirShadowParams, shadowPenumbra/100, shadowUmbra, shadowScattering, shadowDepthOffset);
									shader_set_uniform_f(_u_dirShadowParams2, dcos(angle), -dsin(angle), max(penetration*10, CLE_CFG_EPSILON));
									vertex_submit(_staticVbuff,  pr_trianglelist, -1);
									vertex_submit(_dynamicVbuff, pr_trianglelist, -1);
									gpu_set_cullmode(cull_counterclockwise);
								}
								
								// light
								gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
								gpu_set_zfunc(litType);
								gpu_set_depth(depth);
								if (shaderType == LIGHT_SHADER_BASIC) {
									shader_set(__cle_shDirectLight);
									shader_set_uniform_f(_u_dirLight_params, diffuse*intensity);
								} else
								if (shaderType == LIGHT_SHADER_PHONG) {
									shader_set(__cle_shDirectLightPhong);
									texture_set_stage(_u_dirLightPhong_normalTex, _texNormalMap);
									texture_set_stage(_u_dirLightPhong_materialTex, _texMaterial);
									shader_set_uniform_f(_u_dirLightPhong_params, -dcos(angle), dsin(angle), intensity);
									shader_set_uniform_f(_u_dirLightPhong_params1, normalDistance, diffuse, specular);
								} else {
									shader_set(__cle_shDirectLightBRDF);
									texture_set_stage(_u_dirLightBRDF_normalTex, _texNormalMap);
									texture_set_stage(_u_dirLightBRDF_materialTex, _texMaterial);
									texture_set_stage(_u_dirLightBRDF_albedoTex, _texAlbedo);
									texture_set_stage(_u_dirLightBRDF_reflectionTex, _texReflections);
									shader_set_uniform_f(_u_dirLightBRDF_params, -dcos(angle), dsin(angle), intensity);
									shader_set_uniform_f(_u_dirLightBRDF_params1, normalDistance, diffuse, specular, reflection);
								}
								// draw light quad (full camera size)
								if (CLE_CFG_CAMERA_ROTATION) {
									draw_sprite_ext(__cle_sprQuad, 0, _camCenterX, _camCenterY, _quadXscale, _quadYscale, _camAngle, color, 1); // with rotation
								} else {
									draw_sprite_stretched_ext(__cle_sprPixel, 0, _camX, _camY, _camW, _camH, color, 1); // without rotation
								}
							}
						#endregion
						
						#region >> Shape Lights
							#region uniforms
								static _u_shapeLight_params = shader_get_uniform(__cle_shShapeLight, "u_params"); // intensity, inner, falloff, levels
								
								static _u_shapeLightPhong_normalTex = shader_get_sampler_index(__cle_shShapeLightPhong, "u_normalTex");
								static _u_shapeLightPhong_materialTex = shader_get_sampler_index(__cle_shShapeLightPhong, "u_materialTex");
								static _u_shapeLightPhong_params = shader_get_uniform(__cle_shShapeLightPhong, "u_params"); // angle
								static _u_shapeLightPhong_params2 = shader_get_uniform(__cle_shShapeLightPhong, "u_params2"); // intensity, inner, falloff, levels
								static _u_shapeLightPhong_params3 = shader_get_uniform(__cle_shShapeLightPhong, "u_params3"); // normalDistance, specular
								
								static _u_shapeLightBRDF_normalTex = shader_get_sampler_index(__cle_shShapeLightBRDF, "u_normalTex");
								static _u_shapeLightBRDF_materialTex = shader_get_sampler_index(__cle_shShapeLightBRDF, "u_materialTex");
								static _u_shapeLightBRDF_albedoTex = shader_get_sampler_index(__cle_shShapeLightBRDF, "u_albedoTex");
								static _u_shapeLightBRDF_reflectionTex = shader_get_sampler_index(__cle_shShapeLightBRDF, "u_reflectionTex");
								static _u_shapeLightBRDF_params = shader_get_uniform(__cle_shShapeLightBRDF, "u_params"); // angle
								static _u_shapeLightBRDF_params2 = shader_get_uniform(__cle_shShapeLightBRDF, "u_params2"); // intensity, inner, falloff, levels
								static _u_shapeLightBRDF_params3 = shader_get_uniform(__cle_shShapeLightBRDF, "u_params3"); // normalDistance, specular, reflection
							#endregion
							
							// for each shape light
							with(__cle_objShapeLight) {
								if (!enabled) continue;
								
								// shadow
								if (castShadows) {
									gpu_set_blendmode_ext_sepalpha(_shadowsBlendMode);
									gpu_set_zfunc(shadowLitType);
									gpu_set_cullmode(selfShadows ? cull_noculling : cull_counterclockwise);
									shader_set(__cle_shVertShadow);
									shader_set_uniform_f(_u_shadowParams, shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset);
									shader_set_uniform_f(_u_shadowParams2, x, y, max(penetration, CLE_CFG_EPSILON));
									vertex_submit(_staticVbuff,  pr_trianglelist, -1);
									vertex_submit(_dynamicVbuff, pr_trianglelist, -1);
									gpu_set_cullmode(cull_counterclockwise);
								}
								
								// light
								if (verticesAmount > 0) {
									gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
									gpu_set_zfunc(litType);
									gpu_set_depth(depth); // necessary for the alpha quad
									if (shaderType == LIGHT_SHADER_BASIC) {
										shader_set(__cle_shShapeLight);
										shader_set_uniform_f(_u_shapeLight_params, diffuse*intensity, inner, falloff, levels);
									} else
									if (shaderType == LIGHT_SHADER_PHONG) {
										shader_set(__cle_shShapeLightPhong);
										texture_set_stage(_u_shapeLightPhong_normalTex, _texNormalMap);
										texture_set_stage(_u_shapeLightPhong_materialTex, _texMaterial);
										shader_set_uniform_f(_u_shapeLightPhong_params, angle);
										shader_set_uniform_f(_u_shapeLightPhong_params2, intensity, inner, falloff, levels);
										shader_set_uniform_f(_u_shapeLightPhong_params3, normalDistance, diffuse, specular);
									} else {
										shader_set(__cle_shShapeLightBRDF);
										texture_set_stage(_u_shapeLightBRDF_normalTex, _texNormalMap);
										texture_set_stage(_u_shapeLightBRDF_materialTex, _texMaterial);
										texture_set_stage(_u_shapeLightBRDF_albedoTex, _texAlbedo);
										texture_set_stage(_u_shapeLightBRDF_reflectionTex, _texReflections);
										shader_set_uniform_f(_u_shapeLightBRDF_params, angle);
										shader_set_uniform_f(_u_shapeLightBRDF_params2, intensity, inner, falloff, levels);
										shader_set_uniform_f(_u_shapeLightBRDF_params3, normalDistance, diffuse, specular, reflection);
									}
									// draw light shape vertex buffer
									matrix_set(matrix_world, matrix); // the matrix is already changing z to depth
									vertex_submit(vertexBuffer, pr_trianglestrip, -1);
									matrix_set(matrix_world, _oldMatrix);
									// draw quad to alpha only
									gpu_set_colorwriteenable(false, false, false, true);
									shader_reset();
									if (CLE_CFG_CAMERA_ROTATION) {
										draw_sprite_ext(__cle_sprQuad, 0, _camCenterX, _camCenterY, _quadXscale, _quadYscale, _camAngle, c_black, 1); // with rotation
									} else {
										draw_sprite_stretched_ext(__cle_sprPixel, 0, _camX, _camY, _camW, _camH, c_black, 1); // without rotation
									}
									gpu_set_colorwriteenable(true, true, true, true);
								}
							}
						#endregion
						
						#region >> Spot Lights
							#region uniforms + shaders
								static _u_spotLight_params = shader_get_uniform(__cle_shSpotLight, "u_params"); // x, y, radius
								static _u_spotLight_params2 = shader_get_uniform(__cle_shSpotLight, "u_params2"); // intensity, inner, falloff, levels
								static _u_spotLight_params3 = shader_get_uniform(__cle_shSpotLight, "u_params3"); // spotDirectionXYZ, width
								static _u_spotLight_params4 = shader_get_uniform(__cle_shSpotLight, "u_params4"); // spotFOV, spotSmoothness, spotDistance
								
								static _u_spotLightPhong_normalTex = shader_get_sampler_index(__cle_shSpotLightPhong, "u_normalTex");
								static _u_spotLightPhong_materialTex = shader_get_sampler_index(__cle_shSpotLightPhong, "u_materialTex");
								static _u_spotLightPhong_params = shader_get_uniform(__cle_shSpotLightPhong, "u_params"); // x, y, radius
								static _u_spotLightPhong_params2 = shader_get_uniform(__cle_shSpotLightPhong, "u_params2"); // intensity, inner, falloff, levels
								static _u_spotLightPhong_params3 = shader_get_uniform(__cle_shSpotLightPhong, "u_params3"); // spotDirectionXYZ, width
								static _u_spotLightPhong_params4 = shader_get_uniform(__cle_shSpotLightPhong, "u_params4"); // spotFOV, spotSmoothness, spotDistance
								static _u_spotLightPhong_params5 = shader_get_uniform(__cle_shSpotLightPhong, "u_params5"); // normalDistance, diffuse, specular
								static _u_spotLightPhong_cookieTexture = shader_get_sampler_index(__cle_shSpotLightPhong, "u_cookieTexture");
								static _u_spotLightPhong_cookieTextureUVs = shader_get_uniform(__cle_shSpotLightPhong, "u_cookieAtlasUVrect");
								
								static _u_spotLightBRDF_albedoTex = shader_get_sampler_index(__cle_shSpotLightBRDF, "u_albedoTex");
								static _u_spotLightBRDF_normalTex = shader_get_sampler_index(__cle_shSpotLightBRDF, "u_normalTex");
								static _u_spotLightBRDF_materialTex = shader_get_sampler_index(__cle_shSpotLightBRDF, "u_materialTex");
								static _u_spotLightBRDF_reflectionTex = shader_get_sampler_index(__cle_shSpotLightBRDF, "u_reflectionTex");
								static _u_spotLightBRDF_params = shader_get_uniform(__cle_shSpotLightBRDF, "u_params"); // x, y, radius
								static _u_spotLightBRDF_params2 = shader_get_uniform(__cle_shSpotLightBRDF, "u_params2"); // intensity, inner, falloff, levels
								static _u_spotLightBRDF_params3 = shader_get_uniform(__cle_shSpotLightBRDF, "u_params3"); // spotDirectionXYZ, width
								static _u_spotLightBRDF_params4 = shader_get_uniform(__cle_shSpotLightBRDF, "u_params4"); // spotFOV, spotSmoothness, spotDistance
								static _u_spotLightBRDF_params5 = shader_get_uniform(__cle_shSpotLightBRDF, "u_params5"); // normalDistance, diffuse, specular, reflection
								static _u_spotLightBRDF_cookieTexture = shader_get_sampler_index(__cle_shSpotLightBRDF, "u_cookieTexture");
								static _u_spotLightBRDF_cookieTextureUVs = shader_get_uniform(__cle_shSpotLightBRDF, "u_cookieAtlasUVrect");
							#endregion
							
							// for each light
							var _tilt, _cookieUVs;
							with(__cle_objSpotLight) {
								if (!enabled) continue;
								
								// shadow
								if (castShadows) {
									gpu_set_blendmode_ext_sepalpha(_shadowsBlendMode);
									gpu_set_zfunc(shadowLitType);
									gpu_set_cullmode(selfShadows ? cull_noculling : cull_counterclockwise);
									shader_set(__cle_shVertShadow);
									shader_set_uniform_f(_u_shadowParams, shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset);
									shader_set_uniform_f(_u_shadowParams2, x, y, max(penetration, CLE_CFG_EPSILON));
									vertex_submit(_staticVbuff,  pr_trianglelist, -1);
									vertex_submit(_dynamicVbuff, pr_trianglelist, -1);
									gpu_set_cullmode(cull_counterclockwise);
								}
								
								// lights
								gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
								gpu_set_zfunc(litType);
								gpu_set_depth(depth);
								_tilt = lerp(270+CLE_CFG_EPSILON, 360, tilt);
								if (shaderType == LIGHT_SHADER_BASIC) {
									shader_set(__cle_shSpotLight);
									shader_set_uniform_f(_u_spotLight_params, x, y, radius);
									shader_set_uniform_f(_u_spotLight_params2, diffuse*intensity, inner, falloff, levels);
									shader_set_uniform_f(_u_spotLight_params3, dcos(angle)*dcos(_tilt), -dsin(angle)*dcos(_tilt), dsin(_tilt), width);
									shader_set_uniform_f(_u_spotLight_params4, degtorad(spotFOV), max(spotSmoothness, CLE_CFG_EPSILON), spotDistance);
								} else
								if (shaderType == LIGHT_SHADER_PHONG) {
									shader_set(__cle_shSpotLightPhong);
									texture_set_stage(_u_spotLightPhong_normalTex, _texNormalMap);
									texture_set_stage(_u_spotLightPhong_materialTex, _texMaterial);
									shader_set_uniform_f(_u_spotLightPhong_params, x, y, radius);
									shader_set_uniform_f(_u_spotLightPhong_params2, intensity, inner, falloff, levels);
									shader_set_uniform_f(_u_spotLightPhong_params3, dcos(angle)*dcos(_tilt), -dsin(angle)*dcos(_tilt), dsin(_tilt), width);
									shader_set_uniform_f(_u_spotLightPhong_params4, degtorad(spotFOV), max(spotSmoothness, CLE_CFG_EPSILON), spotDistance);
									shader_set_uniform_f(_u_spotLightPhong_params5, max(normalDistance-1, 1), diffuse, specular);
									_cookieUVs = texture_get_uvs(cookieTexture);
									shader_set_uniform_f(_u_spotLightPhong_cookieTextureUVs, _cookieUVs[0], _cookieUVs[1], _cookieUVs[2], _cookieUVs[3]);
									texture_set_stage(_u_spotLightPhong_cookieTexture, cookieTexture);
								} else {
									shader_set(__cle_shSpotLightBRDF);
									texture_set_stage(_u_spotLightBRDF_albedoTex, _texAlbedo);
									texture_set_stage(_u_spotLightBRDF_normalTex, _texNormalMap);
									texture_set_stage(_u_spotLightBRDF_materialTex, _texMaterial);
									texture_set_stage(_u_spotLightBRDF_reflectionTex, _texReflections);
									shader_set_uniform_f(_u_spotLightBRDF_params, x, y, radius);
									shader_set_uniform_f(_u_spotLightBRDF_params2, intensity, inner, falloff, levels);
									shader_set_uniform_f(_u_spotLightBRDF_params3, dcos(angle)*dcos(_tilt), -dsin(angle)*dcos(_tilt), dsin(_tilt), width);
									shader_set_uniform_f(_u_spotLightBRDF_params4, degtorad(spotFOV), max(spotSmoothness, CLE_CFG_EPSILON), spotDistance);
									shader_set_uniform_f(_u_spotLightBRDF_params5, max(normalDistance-1, 1), diffuse, specular, reflection);
									_cookieUVs = texture_get_uvs(cookieTexture);
									shader_set_uniform_f(_u_spotLightBRDF_cookieTextureUVs, _cookieUVs[0], _cookieUVs[1], _cookieUVs[2], _cookieUVs[3]);
									texture_set_stage(_u_spotLightBRDF_cookieTexture, cookieTexture);
								}
								
								// draw light quad (full camera size)
								if (CLE_CFG_CAMERA_ROTATION) {
									draw_sprite_ext(__cle_sprQuad, 0, _camCenterX, _camCenterY, _quadXscale, _quadYscale, _camAngle, color, 1); // with rotation
								} else {
									draw_sprite_stretched_ext(__cle_sprPixel, 0, _camX, _camY, _camW, _camH, color, 1); // without rotation
								}
							}
						#endregion
						
						#region >> Point Lights
							#region uniforms + shaders
								static _u_pointLight_params = shader_get_uniform(__cle_shPointLight, "u_params"); // x, y, radius
								static _u_pointLight_params2 = shader_get_uniform(__cle_shPointLight, "u_params2"); // intensity, inner, falloff, levels
								
								static _u_pointLightPhong_normalTex = shader_get_sampler_index(__cle_shPointLightPhong, "u_normalTex");
								static _u_pointLightPhong_materialTex = shader_get_sampler_index(__cle_shPointLightPhong, "u_materialTex");
								static _u_pointLightPhong_params = shader_get_uniform(__cle_shPointLightPhong, "u_params"); // x, y, radius
								static _u_pointLightPhong_params2 = shader_get_uniform(__cle_shPointLightPhong, "u_params2"); // intensity, inner, falloff, levels
								static _u_pointLightPhong_params3 = shader_get_uniform(__cle_shPointLightPhong, "u_params3"); // normalDistance, diffuse, specular
								
								static _u_pointLightBRDF_albedoTex = shader_get_sampler_index(__cle_shPointLightBRDF, "u_albedoTex");
								static _u_pointLightBRDF_reflectionTex = shader_get_sampler_index(__cle_shPointLightBRDF, "u_reflectionTex");
								static _u_pointLightBRDF_normalTex = shader_get_sampler_index(__cle_shPointLightBRDF, "u_normalTex");
								static _u_pointLightBRDF_materialTex = shader_get_sampler_index(__cle_shPointLightBRDF, "u_materialTex");
								static _u_pointLightBRDF_params = shader_get_uniform(__cle_shPointLightBRDF, "u_params"); // x, y, radius
								static _u_pointLightBRDF_params2 = shader_get_uniform(__cle_shPointLightBRDF, "u_params2"); // intensity, inner, falloff, levels
								static _u_pointLightBRDF_params3 = shader_get_uniform(__cle_shPointLightBRDF, "u_params3"); // normalDistance, diffuse, specular, reflection
							#endregion
							
							// for each point light (shadow draw + light quad draw)
							with(__cle_objPointLight) {
								if (!enabled) continue;
								
								// shadow
								if (castShadows) {
									gpu_set_blendmode_ext_sepalpha(_shadowsBlendMode);
									gpu_set_zfunc(shadowLitType);
									gpu_set_cullmode(selfShadows ? cull_noculling : cull_counterclockwise);
									shader_set(__cle_shVertShadow);
									shader_set_uniform_f(_u_shadowParams, shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset);
									shader_set_uniform_f(_u_shadowParams2, x, y, max(penetration, CLE_CFG_EPSILON));
									vertex_submit(_staticVbuff,  pr_trianglelist, -1);
									vertex_submit(_dynamicVbuff, pr_trianglelist, -1);
									gpu_set_cullmode(cull_counterclockwise);
								}
								
								// lights
								gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
								gpu_set_zfunc(litType);
								gpu_set_depth(depth);
								if (shaderType == LIGHT_SHADER_BASIC) {
									shader_set(__cle_shPointLight);
									shader_set_uniform_f(_u_pointLight_params, x, y, radius);
									shader_set_uniform_f(_u_pointLight_params2, diffuse*intensity, inner, falloff, levels);
								} else
								if (shaderType == LIGHT_SHADER_PHONG) {
									shader_set(__cle_shPointLightPhong);
									texture_set_stage(_u_pointLightPhong_normalTex, _texNormalMap);
									texture_set_stage(_u_pointLightPhong_materialTex, _texMaterial);
									shader_set_uniform_f(_u_pointLightPhong_params, x, y, radius);
									shader_set_uniform_f(_u_pointLightPhong_params2, intensity, inner, falloff, levels);
									shader_set_uniform_f(_u_pointLightPhong_params3, normalDistance, diffuse, specular);
								} else {
									shader_set(__cle_shPointLightBRDF);
									texture_set_stage(_u_pointLightBRDF_normalTex, _texNormalMap);
									texture_set_stage(_u_pointLightBRDF_materialTex, _texMaterial);
									texture_set_stage(_u_pointLightBRDF_albedoTex, _texAlbedo);
									texture_set_stage(_u_pointLightBRDF_reflectionTex, _texReflections);
									shader_set_uniform_f(_u_pointLightBRDF_params, x, y, radius);
									shader_set_uniform_f(_u_pointLightBRDF_params2, intensity, inner, falloff, levels);
									shader_set_uniform_f(_u_pointLightBRDF_params3, normalDistance, diffuse, specular, reflection);
								}
								
								// draw light quad (full camera size)
								if (CLE_CFG_CAMERA_ROTATION) {
									draw_sprite_ext(__cle_sprQuad, 0, _camCenterX, _camCenterY, _quadXscale, _quadYscale, _camAngle, color, 1); // with rotation
								} else {
									draw_sprite_stretched_ext(__cle_sprPixel, 0, _camX, _camY, _camW, _camH, color, 1); // without rotation
								}
							}
							
						#endregion
						
						#region >> Sprite Lights
							#region uniforms + shaders
								static _u_spriteLight_params = shader_get_uniform(__cle_shSpriteLight, "u_params"); // intensity
								
								static _u_spriteLightPhong_normalTex = shader_get_sampler_index(__cle_shSpriteLightPhong, "u_normalTex");
								static _u_spriteLightPhong_materialTex = shader_get_sampler_index(__cle_shSpriteLightPhong, "u_materialTex");
								static _u_spriteLightPhong_params = shader_get_uniform(__cle_shSpriteLightPhong, "u_params"); // x, y, intensity
								static _u_spriteLightPhong_params2 = shader_get_uniform(__cle_shSpriteLightPhong, "u_params2"); // normalDistance, diffuse, specular
								
								static _u_spriteLightBRDF_normalTex = shader_get_sampler_index(__cle_shSpriteLightBRDF, "u_normalTex");
								static _u_spriteLightBRDF_materialTex = shader_get_sampler_index(__cle_shSpriteLightBRDF, "u_materialTex");
								static _u_spriteLightBRDF_albedoTex = shader_get_sampler_index(__cle_shSpriteLightBRDF, "u_albedoTex");
								static _u_spriteLightBRDF_reflectionTex = shader_get_sampler_index(__cle_shSpriteLightBRDF, "u_reflectionTex");
								static _u_spriteLightBRDF_params = shader_get_uniform(__cle_shSpriteLightBRDF, "u_params"); // x, y, intensity
								static _u_spriteLightBRDF_params2 = shader_get_uniform(__cle_shSpriteLightBRDF, "u_params2"); // normalDistance, diffuse, specular, reflection
							#endregion
							
							// for each sprite light
							with(__cle_objSpriteLight) {
								if (!enabled) continue; // || !sprite_exists(sprite_index)
								
								// shadow
								if (castShadows) {
									gpu_set_blendmode_ext_sepalpha(_shadowsBlendMode);
									gpu_set_zfunc(shadowLitType);
									gpu_set_cullmode(selfShadows ? cull_noculling : cull_counterclockwise);
									shader_set(__cle_shVertShadow);
									shader_set_uniform_f(_u_shadowParams, shadowPenumbra, shadowUmbra, shadowScattering, shadowDepthOffset);
									shader_set_uniform_f(_u_shadowParams2, x, y, max(penetration, CLE_CFG_EPSILON));
									vertex_submit(_staticVbuff,  pr_trianglelist, -1);
									vertex_submit(_dynamicVbuff, pr_trianglelist, -1);
									gpu_set_cullmode(cull_counterclockwise);
								}
								
								// lights
								gpu_set_blendmode_ext_sepalpha(_lightsBlendMode);
								gpu_set_zfunc(litType);
								gpu_set_depth(depth);
								if (shaderType == LIGHT_SHADER_BASIC) {
									shader_set(__cle_shSpriteLight);
									shader_set_uniform_f(_u_spriteLight_params, image_alpha*diffuse*intensity);
								} else
								if (shaderType == LIGHT_SHADER_PHONG) {
									shader_set(__cle_shSpriteLightPhong);
									texture_set_stage(_u_spriteLightPhong_normalTex, _texNormalMap);
									texture_set_stage(_u_spriteLightPhong_materialTex, _texMaterial);
									shader_set_uniform_f(_u_spriteLightPhong_params, x, y, image_alpha*intensity);
									shader_set_uniform_f(_u_spriteLightPhong_params2, normalDistance, diffuse, specular);
								} else {
									shader_set(__cle_shSpriteLightBRDF);
									texture_set_stage(_u_spriteLightBRDF_normalTex, _texNormalMap);
									texture_set_stage(_u_spriteLightBRDF_materialTex, _texMaterial);
									texture_set_stage(_u_spriteLightBRDF_albedoTex, _texAlbedo);
									texture_set_stage(_u_spriteLightBRDF_reflectionTex, _texReflections);
									shader_set_uniform_f(_u_spriteLightBRDF_params, x, y, image_alpha*intensity);
									shader_set_uniform_f(_u_spriteLightBRDF_params2, normalDistance, diffuse, specular, reflection);
								}
								// draw light quad
								draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, 1);
								// draw fullscreen quad to alpha only (this is to help shadow occlusion)
								if (castShadows) {
									gpu_set_colorwriteenable(false, false, false, true);
									shader_reset();
									if (CLE_CFG_CAMERA_ROTATION) {
										draw_sprite_ext(__cle_sprQuad, 0, _camCenterX, _camCenterY, _quadXscale, _quadYscale, _camAngle, c_black, 1); // with rotation
									} else {
										draw_sprite_stretched_ext(__cle_sprPixel, 0, _camX, _camY, _camW, _camH, c_black, 1); // without rotation
									}
									gpu_set_colorwriteenable(true, true, true, true);
								}
							}
						#endregion
						
						gpu_set_blendmode_ext(bm_src_alpha, bm_one); // additive
						
						#region >> Basic Lights
							#region uniforms
								static _u_basicLight_intensity = shader_get_uniform(__cle_shBasicLight, "u_intensity");
							#endregion
							
							gpu_set_zfunc(cmpfunc_lessequal);
							shader_set(__cle_shBasicLight);
							with(__cle_objBasicLight) {
								if (enabled) {
									visible = false;
									shader_set_uniform_f(_u_basicLight_intensity, intensity);
									gpu_set_depth(depth);
									event_perform(ev_draw, 0);
								}
							}
						#endregion
						
						shader_reset();
						gpu_set_depth(_oldDepth);
						
						#region Renderables
							var _renderablesList = _pass.renderables;
							var _renderablesAmount = ds_list_size(_renderablesList);
							if (_renderablesAmount > 0) {
								var i = 0;
								repeat(_renderablesAmount) {
									_renderablesList[| i++](self);
								}
							}
						#endregion
						
						gpu_pop_state(); // <<<<<<<<<
					surface_reset_target();
					_texLightmap = __lightmapSurfaceTex; // override
					
					#region Lightmap Luminance Buffer (CPU HEAVY!)
					if (__isGeneratingLightsCollision) {
						// Generate light data to be read later with GetLightsLuminanceAt().
						// This is costly to performance, even with 1 pixel, there is no way to optimize further.
						var _passSurface = _pass.surface;
						__lightmapBytesPerPixel = __crystal_surface_format_get_size(_passSurface);
						if (__lightmapBuffer == undefined) {
							__lightmapSurfaceWidth = surface_get_width(_passSurface);
							__lightmapSurfaceHeight = surface_get_height(_passSurface);
							__lightmapBuffer = buffer_create(__lightmapSurfaceWidth * __lightmapSurfaceHeight * __lightmapBytesPerPixel, buffer_fixed, 1);
						}
						__lightmapBufferUpdateTime -= 1;
						if (__lightmapBufferUpdateTime <= 0) {
							__lightmapBufferUpdateTime = __lightmapBufferUpdateTimeBase;
							buffer_get_surface(__lightmapBuffer, _passSurface, 0); // (T.T)
						}
					} else {
						if (__lightmapBuffer != undefined) {
							buffer_delete(__lightmapBuffer);
							__lightmapBuffer = undefined;
						}
					}
					#endregion
					
				} else {
					// free surface if it existed before, since we are not using it
					if (surface_exists(_pass.surface)) {
						surface_free(_pass.surface);
						__lightmapSurfaceTex = -1;
					}
				}
				
				//gpu_set_stencil_enable(false);
			#endregion
			
			// ==============================================
			// ############# DEFERRED RENDERING #############
			
			#region Combine: Draw surfaces to a final surface
				#region uniforms
					static __uniRenderLightsBlendMode = shader_get_uniform(__cle_shDeferredRender, "u_lightsBlendMode")
					static __uniRenderResolution = shader_get_uniform(__cle_shDeferredRender, "u_resolution");
					static __uniRenderCamRect = shader_get_uniform(__cle_shDeferredRender, "u_camRect");
					static __uniRenderAmbientLutTexture = shader_get_sampler_index(__cle_shDeferredRender, "u_ambientColorLutTex");
					static __uniRenderMaterialTexture = shader_get_sampler_index(__cle_shDeferredRender, "u_materialTexture");
					static __uniRenderLightsTexture = shader_get_sampler_index(__cle_shDeferredRender, "u_lightsTexture");
					static __uniRenderEmissiveTexture = shader_get_sampler_index(__cle_shDeferredRender, "u_emissiveTexture");
					static __uniRenderAmbientColor = shader_get_uniform(__cle_shDeferredRender, "u_ambientColor");
					static __uniRenderAmbientColorLUTsize = shader_get_uniform(__cle_shDeferredRender, "u_ambientColorLUTsize");
					static __uniRenderAmbientColorLUTtiles = shader_get_uniform(__cle_shDeferredRender, "u_ambientColorLUTtiles");
					static __uniRenderAmbientColorLUTUVs = shader_get_uniform(__cle_shDeferredRender, "u_ambientColorLutUVs");
					static __uniRenderAmbientIntensity = shader_get_uniform(__cle_shDeferredRender, "u_ambientIntensity");
					static __uniRenderLightsIntensity = shader_get_uniform(__cle_shDeferredRender, "u_lightsIntensity");
					static __uniRenderDitheringEnable = shader_get_uniform(__cle_shDeferredRender, "u_ditheringEnable");
					static __uniRenderDitheringTexture = shader_get_sampler_index(__cle_shDeferredRender, "u_ditheringBayerTexture");
					static __uniRenderDitheringSize = shader_get_uniform(__cle_shDeferredRender, "u_ditheringBayerSize");
					static __uniRenderDitheringUVs = shader_get_uniform(__cle_shDeferredRender, "u_ditheringBayerUVs");
					static __uniRenderDitheringBitLevels = shader_get_uniform(__cle_shDeferredRender, "u_ditheringBitLevels");
					static __uniRenderDitheringThreshold = shader_get_uniform(__cle_shDeferredRender, "u_ditheringThreshold");
				#endregion
				_pass = __renderPass[CRYSTAL_PASS.COMBINE];
				
				// Do deferred rendering
				if (!surface_exists(_pass.surface)) {
					// disable depth buffer for performance, since we don't need it here
					var _oldDisableDepth = surface_get_depth_disable();
					surface_depth_disable(true);
					_pass.surface = surface_create(_surfaceW*_pass.resolution, _surfaceH*_pass.resolution, __surfaceFormat);
					surface_depth_disable(_oldDisableDepth);
				}
				surface_set_target(_pass.surface);
					draw_clear_alpha(c_black, 1);
					gpu_push_state();
					if (__deferredFunction == undefined) {
						shader_set(__cle_shDeferredRender);
							shader_set_uniform_f(__uniRenderResolution, _surfaceW, _surfaceH);
							shader_set_uniform_f(__uniRenderCamRect, _camX, _camY, _camW, _camH);
							shader_set_uniform_i(__uniRenderLightsBlendMode, __lightsBlendMode);
							// textures
							texture_set_stage(__uniRenderAmbientLutTexture, __ambientLutTex);
							texture_set_stage(__uniRenderMaterialTexture, _texMaterial);
							texture_set_stage(__uniRenderLightsTexture, _texLightmap);
							texture_set_stage(__uniRenderEmissiveTexture, _texEmissive);
							texture_set_stage(__uniRenderDitheringTexture, __ditheringBayerTex);
							gpu_set_tex_filter_ext(__uniRenderAmbientLutTexture, true);
							gpu_set_tex_repeat_ext(__uniRenderAmbientLutTexture, false);
							gpu_set_tex_filter_ext(__uniRenderDitheringTexture, false);
							gpu_set_tex_repeat_ext(__uniRenderDitheringTexture, false);
							//gpu_set_tex_mip_enable_ext(__uniRenderAmbientLutTexture, mip_off);
							// ambient and confs
							shader_set_uniform_f(__uniRenderAmbientColorLUTUVs, __ambientLutTexUVs[0], __ambientLutTexUVs[1], __ambientLutTexUVs[2], __ambientLutTexUVs[3]);
							shader_set_uniform_f(__uniRenderAmbientColorLUTsize, __ambientLutWidth, __ambientLutHeight);
							shader_set_uniform_f(__uniRenderAmbientColorLUTtiles, __ambientLutTilesH, __ambientLutTilesV);
							shader_set_uniform_f_array(__uniRenderAmbientColor, __ambientLightColorShader);
							shader_set_uniform_f(__uniRenderAmbientIntensity, __ambientLightIntensity);
							shader_set_uniform_f(__uniRenderLightsIntensity, __lightsIntensity);
							// dithering
							shader_set_uniform_f(__uniRenderDitheringEnable, __isDitheringEnabled);
							shader_set_uniform_f(__uniRenderDitheringUVs, __ditheringBayerTexUVs[0], __ditheringBayerTexUVs[1], __ditheringBayerTexUVs[2], __ditheringBayerTexUVs[3]);
							shader_set_uniform_f(__uniRenderDitheringSize, __ditheringBayerSize);
							shader_set_uniform_f(__uniRenderDitheringBitLevels, __ditheringBitLevels);
							shader_set_uniform_f(__uniRenderDitheringThreshold, __ditheringThreshold);
							// draw game screen surface
							gpu_set_blendenable(false);
							gpu_set_zwriteenable(false);
							gpu_set_ztestenable(false);
							var _alphaTest = gpu_get_alphatestenable();
							gpu_set_alphatestenable(false);
							draw_surface_stretched(_surface, 0, 0, _surfaceW, _surfaceH);
							gpu_set_alphatestenable(_alphaTest);
						shader_reset();
					} else {
						// If using custom render function, call it (the context is self)
						__deferredFunction(_surface, _surfaceW, _surfaceH, _camX, _camY, _camW, _camH, _texMaterial, _texLightmap, _texEmissive);
					}
					// After (still on the same surface)
					// No depth support! ~ should be used for >WORLD-SPACE< UI-related only.
					
					#region >> Unlit
						var _layersArray = __matCombineLayers,
							_layersAmount = ds_list_size(_layersArray),
							_renderablesList = _pass.renderables,
							_renderablesAmount = ds_list_size(_renderablesList);
						if (_layersAmount > 0 || _renderablesAmount > 0) {
							gpu_set_blendenable(true);
							gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
							
							#region Layers (surfaces)
								if (_layersAmount > 0) {
									// apply ortho camera
									camera_apply(__surfaceCamera);
									//render
									var _oldDepth = gpu_get_depth();
									var i = 0;
									repeat(_layersAmount) {
										with(_layersArray[| i]) {
											// destroy
											if (__destroyed) {
												ds_list_delete(_layersArray, i);
											} else {
												// draw normal surfaces
												if (__isRenderEnabled && surface_exists(__surface)) {
													gpu_set_depth(depth);
													if (__layerEffect == undefined) {
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
													} else {
														__layerEffect.Begin();
														draw_surface_stretched(__surface, 0, 0, _surfaceW, _surfaceH);
														__layerEffect.End();
													}
												}
												++i;
											}
										}
									}
									gpu_set_depth(_oldDepth);
								}
							#endregion
							
							camera_apply(_camera);
							
							#region Renderables
								if (_renderablesAmount > 0) {
									var i = 0;
									repeat(_renderablesAmount) {
										_renderablesList[| i++](self);
									}
								}
							#endregion
						}
					
					// debug
					camera_apply(_camera);
					gpu_set_blendenable(true);
					gpu_set_blendmode(bm_normal);
					//draw_rectangle(_camX, _camX, _camX+_camW, _camY+_camH, true);
					//draw_set_color(c_yellow);
					//draw_circle(_camCenterX, _camCenterY, 4, true);
					//draw_set_color(c_purple);
					//draw_circle(_camX, _camY, 16, true);
					//draw_circle(_camX+_camW, _camY+_camH, 16, true);
					//draw_set_color(c_white);
					//with(__cle_objLightDynamic) draw_text(x, y, depth);
					#endregion
					
					gpu_pop_state();
				surface_reset_target();
				__finalRenderSurf = _pass.surface;
			#endregion
			// ==============================================
			__cpuFrameTime = get_timer() - _currentFrameTime;
		} else {
			__cpuFrameTime = 0;
			__finalRenderSurf = _surface;
		}
	}
	
	#endregion
	
	#region DRAW
	
	/// @desc This function draws the lighting renderer's final surface using custom position and size. Can be drawn on any Draw event.
	/// May be useful for split-screen games too (you may want .DrawInViewport() for this...).
	/// @method Draw(x, y, w, h)
	/// @param {Real} x X position where to draw the final surface.
	/// @param {Real} y Y position where to draw the final surface.
	/// @param {Real} w Width of the area to be drawn final surface.
	/// @param {Real} h Height of the area to be drawn final surface.
	static Draw = function(_x, _y, _w, _h) {
		// draw final surface (from renderer or original input surface)
		if (__isDrawEnabled) {
			gpu_push_state();
			gpu_set_blendenable(false);
			gpu_set_zwriteenable(false);
			gpu_set_ztestenable(false);
			gpu_set_alphatestenable(false);
			if (surface_exists(__finalRenderSurf)) {
				draw_surface_stretched(__finalRenderSurf, _x, _y, _w, _h);
			} else {
				draw_surface_stretched(__sourceSurface, _x, _y, _w, _h);
			}
			gpu_pop_state();
		}
	}
	
	/// @method DrawInFullscreen()
	/// @desc Easily draw Lighting renderer's final surface in full screen. It is an easy alternative to the normal .Draw() method.
	///
	/// This function automatically detects the draw event you are drawing (Post-Draw or Draw GUI Begin).
	///
	/// It uses the size of the referenced surface for internal rendering resolution (example: application_surface size).
	/// 
	/// If you are using Post-Processing, you should NOT use this function, but rather use post-processing itself to draw.
	static DrawInFullscreen = function() {
		var _xx = 0, _yy = 0, _width = 0, _height = 0;
		if (event_number == ev_draw_post) {
			if (os_type != os_operagx) {
				var _pos = application_get_position();
				_xx = _pos[0];
				_yy = _pos[1];
				_width = _pos[2]-_pos[0];
				_height = _pos[3]-_pos[1];
			} else {
				if (GM_build_type == "run") {
					var _pos = application_get_position();
					_xx = _pos[0];
					_yy = _pos[1];
					_width = _pos[2]-_pos[0];
					_height = _pos[3]-_pos[1];
				} else {
					_width = browser_width;
					_height = browser_height;
				}
			}
		} else
		if (event_number == ev_gui_begin) {
			_width = display_get_gui_width();
			_height = display_get_gui_height();
		}
		Draw(_xx, _yy, _width, _height);
	}
	
	/// @desc If you are making split-screen games, while in the "Post-Draw" event, it allows you to draw the lighting renderer in the position and size of the selected viewport.
	/// @method DrawInViewport(viewport)
	/// @param {Real} viewport The viewport (0-7) to get position and size.
	static DrawInViewport = function(_viewport) {
		Draw(view_get_xport(_viewport), view_get_yport(_viewport), view_get_wport(_viewport), view_get_hport(_viewport));
	}
	
	#endregion
	#endregion
}

// Utils
#region Utils

/// @desc Defines which renderer is in use for: adding Materials, rendering TimeCycle, adding Shadows, adding Lights, among others.
/// This can be useful for split-screen.
/// @param {Struct.Crystal_Renderer} renderer The new Crystal_Renderer struct.
function crystal_set_renderer(_renderer) {
	global.__CrystalCurrentRenderer = _renderer;
}

/// @desc Get current Crystal_Renderer() struct.
/// @return {Struct.Crystal_Renderer}
function crystal_get_renderer() {
	return global.__CrystalCurrentRenderer;
}

/// @desc This function sends a function that will be executed at the end of a pass. Useful for drawing custom things within each pass.
/// Be careful when setting shaders, as it can change the behavior of some passes (see below). Blendmodes are free to use.
/// Notes on each pass:
/// - Normals: Using shader_set() will remove the current Normal shader. So you can use your own, and "mat_normal_*" functions to set it again.
/// - Emissive: Using shader_set() will remove the current Emissive shader. So you can use your own, and "mat_emission_*" functions to set it again.
/// All other passes are fine to use shader_set().
///
/// If you change the depth, blendmode, alpha, color or something else, this will affect the next function to be called, so you should reset if you don't want this to happen.
///
/// You should call this function at each step (in any event), as the renderer always resets the passes at each frame. You may want to declare the function/method only once in the Create Event, for performance reasons.
/// @param {Enum.CRYSTAL_PASS} pass Pass enum, defines in which pass to render.
/// @param {Method,Function} function The function to be executed. 
function crystal_pass_submit(_pass, _function) {
	ds_list_add(global.__CrystalCurrentRenderer.__renderPass[_pass].renderables, _function);
}

#endregion
