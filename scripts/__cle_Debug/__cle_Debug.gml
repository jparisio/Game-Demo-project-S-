
/*=================================================================================================
	These functions are independent, so if you delete them from the asset, nothing will happen.
=================================================================================================*/

/// Feather ignore all

#region UI INSPECTORS
/// @ignore
function __Crystal_DebugInterfaces() constructor {
	#region =============== LEFT PANEL ======================
	// Top
	// selector
	static PanelClassSelector = function() {
		// Get panel inspector and remove all elements from it so we can add new ones
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Class Selector", true));
		if (!instance_exists(__origin)) {
			_inspector.AddElement(new __Crystal_UIElementText($"\"origin\" instance not found. Can't search for classes to inspect."), _menuA);
			exit;
		}
		
		// Get variables from origin instance (only if is a struct)
		variablesArray = [];
		selectedItem = 0;
		var _variableNamesArray = variable_instance_get_names(__origin);
		var i = 0, isize = array_length(_variableNamesArray), _name = undefined, _variable = undefined;
		repeat(isize) {
			_name = _variableNamesArray[i];
			_variable = __origin[$ _name];
			
			// only add if match
			if (is_struct(_variable) ) {
				var _instanceOf = instanceof(_variable);
				if (string_count("crystal", string_lower(_instanceOf)) > 0) {
					array_push(variablesArray, {
						variable : _variable,
						variableName : _name,
						type : typeof(_variable),
						instOf : _instanceOf,
					});
				}
			}
			++i;
		}
		
		// Create ui items
		_inspector.AddElement(new __Crystal_UIElementText($"Here are listed the classes available in the current origin instance ({object_get_name(__origin.object_index)}). Select one to open and debug it."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("If not all variables are showing, reopen the Class Selector."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		var i = 0, isize = array_length(variablesArray), _item = undefined;
		if (isize > 0) {
			var _items = [];
			repeat(isize) {
				_item = variablesArray[i];
				array_push(_items, $"{_item.variableName} | {_item.instOf} ({_item.type})");
				++i;
			}
			_inspector.AddElement(new __Crystal_UIElementRadio(self, "selectedItem", _items), _menuA);
			_inspector.AddElement(new __Crystal_UIElementButton("Open Selected", function() {
				// Send class struct variable to open it there
				if (array_length(variablesArray) > 0) {
					PanelInspect(variablesArray[selectedItem].variable);
				}
			}), _menuA);
		} else {
			_inspector.AddElement(new __Crystal_UIElementText("ERROR: No variables found."), _menuA);
		}
	}
	
	// renderer
	static PanelClassCrystalRenderer = function() {
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		var _ref = __panelCurrentClass;
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("RENDERER", true));
		_inspector.AddElement(new __Crystal_UIElementText("The Renderer is responsible for rendering lights, shadows and PBR independently, without directly affecting the game's rendering."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isRenderEnabled", "Enable Render", "SetRenderEnable", [-1, true], 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isDrawEnabled", "Enable Drawing", "SetDrawEnable", [-1], 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementEmptySpace(4), _menuA);
		
		// > Rendering
		var _renderingMenu = _inspector.AddElement(new __Crystal_UIElementSection("Rendering", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isHDREnabled", "HDR (High Dynamic Range)", "SetHDREnable", [-1], 0), _renderingMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isHDRLightmapEnabled", "HDR Lightmap", "SetLightsHDREnable", [-1], 0), _renderingMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Passes:"), _renderingMenu);
			_inspector.AddElement(new __Crystal_UIElementCustom(function() {
				_u_alphaBlend = shader_get_uniform(__cle_shAlphaOne, "u_alphaBlend");
				previewSurface = -1;
			}, function(_element, _ui) {
				var _class = __panelCurrentClass;
				__panelInspector.__bake(); // auto bake inspector
				
				// Get stacks info
				var _mx = _ui.__inputCursorX,
					_my = _ui.__inputCursorY,
					_surf = -1,
					_aspectRatio = (surface_get_width(_class.__sourceSurface)/surface_get_height(_class.__sourceSurface)),
					_width = _element.width-8,
					_areaHeight = 0,
					_xOrigin = _element.xx,
					_yOrigin = _element.yy,
					_xx = _xOrigin,
					_yy = _yOrigin,
					_hTiles = 2,
					_cellWidth = (_width / _hTiles),
					_cellHeight = _cellWidth / _aspectRatio;
					
				var i = 0, isize = _class.__renderPassAmount;
				var _drawingData = [];
				repeat(isize) {
					_drawingData[i] = _class.__renderPass[i];
					i++;
				}
				_drawingData[i] = {
					surface : _class.__sourceSurface,
					name : "(Input)"
				};
				
				// Draw stack surfaces
				shader_set(__cle_shAlphaOne);
				draw_set_halign(fa_left);
				var s = 0, ssize = array_length(_drawingData), _data = undefined, _surf = undefined;
				repeat(ssize) {
					_data = _drawingData[s];
					_surf = _data.surface;
					if (surface_exists(_surf)) {
						// wrap
						if (_xx > _width) {
							_xx = _xOrigin;
							_yy += _cellHeight;
						}
						// draw
						if (point_in_rectangle(_mx, _my, _xx, _yy, _xx+_cellWidth, _yy+_cellHeight)) {
							previewSurface = _surf;
						}
						gpu_set_blendmode(bm_normal);
						shader_set_uniform_f(_u_alphaBlend, 0);
						draw_surface_stretched(_surf, _xx, _yy, _cellWidth, _cellHeight);
						gpu_set_blendmode(bm_max);
						shader_set_uniform_f(_u_alphaBlend, 1);
						draw_text(_xx, _yy, _data.name);
						// move
						_xx += _cellWidth;
					}
					++s;
				}
				_yy += _cellHeight;
				
				// Draw Preview Surface
				gpu_set_blendmode(bm_normal);
				if (surface_exists(previewSurface)) {
					_yy += 8;
					var _surfaceWidth = surface_get_width(previewSurface);
					var _surfaceHeight = surface_get_height(previewSurface);
					var _xScale = _width / _surfaceWidth;
					var _yScale = _xScale;
					var _ww = _surfaceWidth*_xScale;
					var _hh = _surfaceHeight*_yScale;
					shader_set_uniform_f(_u_alphaBlend, 0);
					draw_surface_stretched(previewSurface, _xOrigin, _yy, _ww, _hh);
					_yy += _hh;
				}
				shader_reset();
				
				_element.height = (_yy - _yOrigin);
			}), _renderingMenu);
			
			_inspector.AddElement(new __Crystal_UIElementButton("Calculate VRAM Usage", method(_ref, _ref.__calculateVRAM)), _renderingMenu);
			_inspector.AddElement(new __Crystal_UIElementText(,,, function() {
				var _osInfo = os_get_info();
				var _currentVRAM = __cle_bytes_get_size(__panelCurrentClass.__gpuVRAMusage);
				var _availableVRAM = 0;
				switch(os_type) {
					case os_windows:
						_availableVRAM = __cle_bytes_get_size(real(_osInfo[? "video_adapter_dedicatedvideomemory"]));
						break;
					case os_ios:
					case os_tvos:
						_availableVRAM = __cle_bytes_get_size(real(_osInfo[? "totalMemory"]));
						break;
					case os_android:
						_availableVRAM = _osInfo[? "MODEL"];
						break;
					case os_switch:
						_availableVRAM = __cle_bytes_get_size(4294967296); // 4 GB (shared)
						break;
					case os_ps4:
					case os_xboxone:
						_availableVRAM = __cle_bytes_get_size(8589934592); // 8 GB (shared)
						break;
					case os_ps5:
					case os_xboxseriesxs:
						_availableVRAM = __cle_bytes_get_size(17179869184); // 16 GB (shared). NOTE: "Series S" is actually 10 GB!
						break;
				}
				return $"VRAM: {_currentVRAM} / {_availableVRAM}";
			}), _renderingMenu);
			_inspector.AddElement(new __Crystal_UIElementText(,,, function() {
				return $"CPU Frame Time: {__panelCurrentClass.__cpuFrameTime/1000}ms / {(1/game_get_speed(gamespeed_fps))*1000}ms"
			}), _renderingMenu);
			
			// > Secret Settings
			var _menuSecret = _inspector.AddElement(new __Crystal_UIElementSection("Secret Settings", false, 2), _renderingMenu);
				_inspector.AddElement(new __Crystal_UIElementText("WARNING: Changing the render resolution affects the depth buffer (it's not Crystal's fault). So the correct thing to do is to change the input surface resolution directly. This is also valid if you are changing the resolution of individual passes."), _menuSecret);
				_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__renderResolution", "Render Resolution", 0, 1, 0, "SetRenderResolution", [-1], 0), _menuSecret);
				_inspector.AddElement(new __Crystal_UIElementText(,,, function() {return $"{__panelCurrentClass.__renderSurfaceWidth}x{__panelCurrentClass.__renderSurfaceHeight}";}), _menuSecret);
		
		// > Lights
		var _lightsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Lights", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__ambientLightIntensity", "Ambient Intensity", 0, 1), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Ambient Color:"), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementColor(_ref, "__ambientLightColor",,, "SetAmbientColor", [-1], 0), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementEmptySpace(4), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__lightsIntensity", "Lights Intensity", 0, 5), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Lights Blendmode:"), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementRadio(_ref, "__lightsBlendMode", ["Multiply", "Multiply Normalized", "Multiply Linear", "Add"]), _lightsMenu);
			// LIGHTS EDITOR
			var _lightsEditorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Lights Editor", false, 2), _lightsMenu);
				_inspector.AddElement(new __Crystal_UIElementText("Enable the editor to enter light editing mode"), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementCheckbox(self, "__editorIsEnabled", "Enabled"), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementCheckbox(self, "__editorShowLightsOverlays", "Show Overlays"), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementCustom(function(_element) {
					_element.alwaysVisible = true;
				}, function(_element, _ui) {
					_element.height = 0;
					__panelInspector.__bake(); // make sure inspector continues drawing every frame
					// send overlay function for drawing in room space
					if (__editorShowLightsOverlays) {
						ds_list_add(__overlayRenderables, function() {
							var _oldAlpha = draw_get_alpha(),
								_oldColor = draw_get_color();
							draw_set_alpha(0.5);
							// draw position
							draw_set_color(c_white);
							with(__cle_objLightStatic) {
								draw_rectangle(x-2, y-2, x+2, y+2, true);
							}
							with(__cle_objLightDynamic) {
								draw_circle(x, y, 4, true);
							}
							// draw radius
							draw_set_color(c_white);
							with(__cle_objPointLight) {
								draw_set_color(color);
								draw_circle(x, y, radius, true);
							}
							with(__cle_objSpotLight) {
								draw_set_color(color);
								draw_circle(x, y, radius, true);
							}
							with(__cle_objSpriteLight) {
								draw_set_color(image_blend);
								var _rad = max(sprite_get_width(sprite_index), sprite_get_height(sprite_index)) / 2;
								draw_circle(x, y, _rad, true);
							}
							with(__cle_objShapeLight) {
								draw_set_color(color);
								if (path != undefined) draw_path(path, 0, 0, true);
							}
							draw_set_alpha(_oldAlpha);
							draw_set_color(_oldColor);
						});
					}
				}), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementSeparator(), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementText("Light Type:"), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementRadio(self, "__editorLightRadio", ["Basic (Custom)", "Sprite", "Point", "Spot", "Shape", "Direct"]), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementButton("Edit Lights", function() {__editorIsEditingLights = !__editorIsEditingLights;}), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementCustom(, function(_element, _ui) {
					draw_set_color(__editorIsEditingLights ? c_lime : c_white);
					draw_circle(_element.xx+8, _element.yy+8, 8, false);
					draw_set_color(c_white);
					_element.height = 16;
				}), _lightsEditorMenu);
				
				__lightData = new Crystal_LightData();
				var _saveLoadSceneMenu = _inspector.AddElement(new __Crystal_UIElementSection("Save & Load (lightdata)", false, 2), _lightsEditorMenu);
				_inspector.AddElement(new __Crystal_UIElementText("This feature is best suited for real-time testing. Use the room editor in production."), _saveLoadSceneMenu);
				_inspector.AddElement(new __Crystal_UIElementCheckbox(__lightData, "__destroyAllLightsBeforeLoading", "Destroy Before Loading"), _saveLoadSceneMenu);
				_inspector.AddElement(new __Crystal_UIElementButton("Load", function() {
					var _path = filename_path(GM_project_filename) + "datafiles";
					var _file = get_open_filename_ext("Crystal Light Data|*.lightdata", "", _path, "Load Light Data");
					if (_file != "") {
						__lightData.LoadBuffer(buffer_load(_file));
					}
				}), _saveLoadSceneMenu);
				_inspector.AddElement(new __Crystal_UIElementButton("Save", function() {
					var _path = filename_path(GM_project_filename) + "datafiles";
					var _file = get_save_filename_ext("Crystal Light Data|*.lightdata", "", _path, "Save Light Data");
					if (_file != "") {
						__lightData.SaveBuffer(_file);
					}
				}), _saveLoadSceneMenu);
			// -------
			var _ditheringMenu = _inspector.AddElement(new __Crystal_UIElementSection("Dithering", false, 2), _lightsMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Apply Dithering effect to lights and shadows for retro aesthetic. You can change the bayer texture via code."), _ditheringMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isDitheringEnabled", "Dithering Enabled", "SetDitheringEnable", [-1], 0), _ditheringMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__ditheringBitLevels", "Posterization Levels", 0, 256, 1), _ditheringMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__ditheringThreshold", "Dithering Threshold", 0, 1), _ditheringMenu);
			
			var _lightsCollisionMenu = _inspector.AddElement(new __Crystal_UIElementSection("Collision", false, 2), _lightsMenu);
				_inspector.AddElement(new __Crystal_UIElementText("This feature allows you to detect lights pixel color at different positions in the room."), _lightsCollisionMenu);
				_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isGeneratingLightsCollision", "Lights Collision Enabled", "SetLightsCollisionEnable", [-1], 0), _lightsCollisionMenu);
				_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__lightmapBufferUpdateTimeBase", "Update Time", 0, 60), _lightsCollisionMenu);
				
			var _lightsStatsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Stats", false, 2), _lightsMenu);
				_inspector.AddElement(new __Crystal_UIElementText("Lights count (visible)"), _lightsStatsMenu);
				_inspector.AddElement(new __Crystal_UIElementText("",,, function() {
					var _txt = "";
					_txt += $"Dynamic: {instance_number(__cle_objLightDynamic)}\n";
					_txt += $"Static: {instance_number(__cle_objLightStatic)}\n\n";
					_txt += $"Basic: {instance_number(__cle_objBasicLight)}\n";
					_txt += $"Sprite: {instance_number(__cle_objSpriteLight)}\n";
					_txt += $"Point: {instance_number(__cle_objPointLight)}\n";
					_txt += $"Spot: {instance_number(__cle_objSpotLight)}\n";
					_txt += $"Shape: {instance_number(__cle_objShapeLight)}\n";
					_txt += $"Direct: {instance_number(__cle_objDirectLight)}";
					return _txt;
				}), _lightsStatsMenu);
		
		// > Vertex Shadows
		var _vertexShadowsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Vertex Shadows", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementCustom(, function(_element, _ui) {
				var _class = __panelCurrentClass;
				
				var _dynamicSize = ds_list_size(_class.__dynamicShadowsArray);
				var _visibleDynamic = 0;
				var d = 0;
				repeat(_dynamicSize) {with(_class.__dynamicShadowsArray[| d++]) if (!__cull) _visibleDynamic++;}
				
				var _staticSize = ds_list_size(_class.__staticShadowsArray);
				var _visibleStatic = 0;
				var d = 0;
				repeat(_staticSize) {with(_class.__staticShadowsArray[| d++]) if (!__cull) _visibleStatic++;}
				
				var _text = $"Dynamic: {_visibleDynamic}/{_dynamicSize}\nStatic: {_visibleStatic}/{_staticSize}";
				
				draw_set_color(c_white);
				draw_text_ext(_element.xx, _element.yy, _text, -1, _element.width);
				_element.height = string_height_ext(_text, -1, _element.width);
			}), _vertexShadowsMenu);
			_inspector.AddElement(new __Crystal_UIElementText("(visible/total)"), _vertexShadowsMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Update Static Shadows", function() {__panelCurrentClass.__vbuffStaticRebuild = true;}), _vertexShadowsMenu);
			// EDITOR
			_inspector.AddElement(new __Crystal_UIElementText("Shadows:"), _vertexShadowsMenu);
			_inspector.AddElement(new __Crystal_UIElementCustom(function(_element) {
				_element.alwaysVisible = true;
				debugShadowsShaderUniformColor = shader_get_uniform(__cle_shDebugShadow, "u_color");
				showStaticShadowsOverlay = false;
				showDynamicShadowsOverlay = false;
			}, function(_element, _ui) {
				_element.height = 0;
				__panelInspector.__bake(); // make sure inspector continues drawing every frame
				ds_list_add(__overlayRenderables, function() {
					// visualize shadows
					draw_set_color(c_white);
					shader_set(__cle_shDebugShadow);
					shader_set_uniform_f(debugShadowsShaderUniformColor, 1, 0, 1);
					if (showStaticShadowsOverlay) vertex_submit(__panelCurrentClass.__vbuffStatic, pr_linelist, -1);
					shader_set_uniform_f(debugShadowsShaderUniformColor, 0, 1, 1);
					if (showDynamicShadowsOverlay) vertex_submit(__panelCurrentClass.__vbuffDynamic, pr_linelist, -1);
					shader_reset();
				});
				
			}), _vertexShadowsMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(self, "showStaticShadowsOverlay", "Show Static Shadows"), _vertexShadowsMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(self, "showDynamicShadowsOverlay", "Show Dynamic Shadows"), _vertexShadowsMenu);
			// ----
		
		// > Materials
		var _materialsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Materials", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementText("Materials (Normals, Roughness, Metallic, AO, Emissive, Reflections) can be completely disabled if you do not need them. Crystal is smart and automatically doesn't execute code if it's not needed too."), _materialsMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isMaterialsEnabled", "Enabled", "SetMaterialsEnable", [-1], 0), _materialsMenu);
			var _ssrMenu = _inspector.AddElement(new __Crystal_UIElementSection("SSR", false, 2), _materialsMenu);
				_inspector.AddElement(new __Crystal_UIElementText("Screen-space reflections. Only available for BRDF lights."), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isSSREnabled", "SSR Enabled", "SetSSREnable", [-1], 0), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__ssrAlpha", "SSR Alpha", 0, 1), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__ssrSkyAlpha", "Sky Alpha", 0, 1), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementButton("Select Sky Sprite Asset", function() {
				if (__assetSelector != undefined) __uiSystem.RemoveContainer(__assetSelector);
					__assetSelector = method(self, __interfaces.AssetSelector)( function(_sprite) {__panelCurrentClass.__ssrSky=_sprite; __panelInspector.__bake();}, asset_sprite );
				}), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementText("Sky color:"), _ssrMenu);
				_inspector.AddElement(new __Crystal_UIElementColor(_ref, "__ssrSkyColor"), _ssrMenu);
			var _materialsStatsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Stats", false, 2), _materialsMenu);
			_inspector.AddElement(new __Crystal_UIElementCustom(, function(_element, _ui) {
				var _class = __panelCurrentClass;
				var _text =
				"> SPRITES:\n" +
				$"Normals: {ds_list_size(_class.__matNormalSprites)}\n" +
				$"Emissive: {ds_list_size(_class.__matEmissiveSprites)}\n" +
				$"Reflections: {ds_list_size(_class.__matReflectionSprites)}\n" +
				$"Metallic: {ds_list_size(_class.__matMetallicSprites)}\n" +
				$"Roughness: {ds_list_size(_class.__matRoughnessSprites)}\n" +
				$"Ambient Occlusion: {ds_list_size(_class.__matAoSprites)}\n" +
				$"Masks: {ds_list_size(_class.__matMaskSprites)}\n\n" +
				
				"> LAYERS:\n" +
				$"Normals: {ds_list_size(_class.__matNormalLayers)}\n" +
				$"Material (Met, Roug, Ao, Mask): {ds_list_size(_class.__matMaterialLayers)}\n" +
				$"Emissive: {ds_list_size(_class.__matEmissiveLayers)}\n" +
				$"Reflections: {ds_list_size(_class.__matReflectionLayers)}\n" +
				$"Light: {ds_list_size(_class.__matLightLayers)}\n" +
				$"Combine: {ds_list_size(_class.__matCombineLayers)}\n";
				draw_set_color(c_white);
				draw_text_ext(_element.xx, _element.yy, _text, -1, _element.width);
				_element.height = string_height_ext(_text, -1, _element.width);
			}), _materialsStatsMenu);
		
		// > Culling
		var _cullingMenu = _inspector.AddElement(new __Crystal_UIElementSection("Culling", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementText("Culling disables Materials and Lights outside of the camera's view when the camera is moving (or idle, using the auto update timer). Note that you can still control the disabling of lights and materials individually."), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isCullingEnabled", "Enabled"), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSeparator(), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Dynamics:"), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__cullingDynamicsViewBorderSize", "View Border Size", 0, 1000), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__cullingDynamicsViewMoveDistance", "View Move Distance", 0, 100), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__cullingDynamicsAutoUpdateTimerBase", "Auto Update Time", 0, 600), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSeparator(), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Statics:"), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__cullingStaticsViewBorderSize", "View Border Size", 0, 10000), _cullingMenu);
			_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__cullingStaticsViewMoveDistance", "View Move Distance", 0, 1000), _cullingMenu);
		
	}
	
	// material layer
	static PanelClassMaterialLayer = function() {
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		var _ref = __panelCurrentClass;
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("MATERIAL LAYER", true));
		_inspector.AddElement(new __Crystal_UIElementText("MaterialLayer allows you to render any layer (backgrounds, instances, etc.) in any pass (Normals, Emissive, Materials, etc)."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isRenderEnabled", "Enable Render", "SetRenderEnable", [-1, true], 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isDrawEnabled", "Enable Drawing", "SetDrawEnable", [-1], 0), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "depth",, -15000, 15000, 1), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementText("Layers:"), _menuA);
		
		var i = 0, isize = array_length(_ref.__layers);
		repeat(isize) {
			var _lay = _ref.__layers[i];
			var _item = _inspector.AddElement(new __Crystal_UIElementText("",,, function(_element) {
				var _layer = _element._layer;
				var _i = _element._i;
				var _materialType = "N/A";
				switch(_layer.materialType) {
					case CRYSTAL_MATERIAL.METALLIC: _materialType = "Metallic"; break;
					case CRYSTAL_MATERIAL.ROUGHNESS: _materialType = "Roughness"; break;
					case CRYSTAL_MATERIAL.AO: _materialType = "Ambient Occlusion"; break;
					case CRYSTAL_MATERIAL.MASK: _materialType = "Mask"; break;
				}
				return $"{_i}:\nPBR Material Type: {_materialType}\ndepth: {_layer.topDepth}\nRange : \{\n  Top Layer: '{layer_get_name(_layer.topLayerId)}'\n  Bottom Layer: '{layer_get_name(_layer.bottomLayerId)}'\n\}";
			}), _menuA);
			_item._layer = _lay;
			_item._i = i;
			++i;
		}
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("Content:"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCustom(, function(_element, _ui) {
			_element.height = 0;
			__panelInspector.__bake(); // auto bake inspector
		}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSurface(_ref, "__surface"), _menuA);
	}
	
	// layer effects
	// normal from luma
	static PanelClassLayerFXNormalFromLuminance = function() {
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		var _ref = __panelCurrentClass;
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("LAYER EFFECT: Normals Generator", true));
		_inspector.AddElement(new __Crystal_UIElementText("A LayerEffect is responsible for applying a shader to a layer when drawing it. Useful for generating automatic normal maps on layers, for example."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "angle",, 0, 360, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "xScale",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "yScale",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "offsetX",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "offsetY",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "strengthX",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "strengthY",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "thresholdMin",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "thresholdMax",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "blurAmount",, 0, 10, 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "outlineRadius",, -16, 16, 1), _menuA);
	}
	
	// time cycle
	static PanelClassTimeCycle = function() {
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		var _ref = __panelCurrentClass;
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("TIME CYCLE", true));
		_inspector.AddElement(new __Crystal_UIElementText("A TimeCycle is responsible for controlling the ambient light and the intensity of the lights. It also has an internal clock, which can be adjusted. NOTE: It controls the renderer's Ambient LUT and LightsIntensity."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__clockIsEnabled", "Clock Enable", "SetClockEnable", [-1], 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__isCycling", "Cycling Enable", "SetCyclingEnable", [-1], 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__clockSpd", "Clock Speed", 0, 60, 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(_ref, "__clockSpd", ["24 hours", "24 minutes", "24 seconds"], [1/60, 1, 60]), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementText("Time: ",,, function(_element) {
			var _class = __panelCurrentClass;
			return $"{_class.GetTime()} | Day: {_class.__day}\nSun Angle: {_class.__sunAngle}";
		}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__hour", "Hour", 0, 24, 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__minute", "Minute", 0, 59, 0), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__second", "Second", 0, 59, 0), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementText("Cycle Sprites:"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("LMB: Select | RMB: Delete"), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCustom(function() {
			selectedLUTIndex = 0;
		}, function(_element, _ui) {
			var _lutSprites = __panelCurrentClass.__lutSprites;
			var _ww = 24;
			var _hh = 0;
			var _xx = _element.xx;
			var _yy = _element.yy;
			var _sprite = undefined, _color = c_white;
			for(var i = 0; i < array_length(_lutSprites); i++) {
				_sprite = _lutSprites[i];
				_color = c_white;
				_hh = _ww / (sprite_get_width(_sprite)/sprite_get_height(_sprite));
				if (point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, _xx, _yy, _xx+_ww, _yy+_hh)) {
					if (_ui.__inputLeft) {
						_color = c_gray;
					}
					if (_ui.__inputLeftReleased) {
						selectedLUTIndex = i;
						if (__assetSelector != undefined) __uiSystem.RemoveContainer(__assetSelector);
						__assetSelector = method(self, __interfaces.AssetSelector)( function(_sprite) {__panelCurrentClass.__lutSprites[selectedLUTIndex]=_sprite; __panelInspector.__bake();}, asset_sprite );
					}
					if (_ui.__inputRightReleased) {
						array_delete(_lutSprites, i, 1);
					}
				}
				if (sprite_exists(_sprite)) {
					draw_sprite_stretched_ext(_sprite, 0, _xx, _yy, _ww, _hh, _color, 1); // w / aspect
					_xx += _ww + 4;
				}
			}
			_element.height = _ww + 4;
		}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementButton("Add", function() {
			array_push(__panelCurrentClass.__lutSprites, __cle_sprNeutralLUT);
		}), _menuA);
	}
	
	// cookie
	static PanelClassCookie = function() {
		var _inspector = __panelInspector;
		_inspector.RemoveElements();
		var _ref = __panelCurrentClass;
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("COOKIE GENERATOR", true));
		_inspector.AddElement(new __Crystal_UIElementText("A CookieGenerator is capable of generating a gobo texture that can be used in a spot light. The industry standard .IES format is also supported."), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__smooth", "Smooth"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__polarProjectionEnable", "Polar Projection"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_ref, "__polarProjectionRadial", "Radial Projection"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__width", "Width", 16, 2048, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__intensity", "Intensity", 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__power", "Power", 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__distortionAmount", "Distortion Amount", -5, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__distortionSmoothness", "Distortion Smoothness", 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__distortionFrequency", "Distortion Frequency", 0, 100), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__outerSmoothness", "Outer Smoothness", 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__innerSmoothness", "Inner Smoothness", 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__innerScale", "Inner Scale", 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(_ref, "__outerScale", "Outer Scale", 0, 15), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementButton("Load .IES Photometry Light", function() {
			var _file = get_open_filename("IES Photometry Files|*.ies;*.IES", "");
			if (_file != "") {
				var _buffer = buffer_load(_file);
				__panelCurrentClass.FromIES(_buffer);
				buffer_delete(_buffer);
			}
		}), _menuA);
		__iesTempSprite = -1;
		_inspector.AddElement(new __Crystal_UIElementButton("Load Sprite", function() {
			var _file = get_open_filename("Image Files|*.png;*.jpg;*.jpeg;*.gif", "");
			if (_file != "") {
				if (sprite_exists(__iesTempSprite)) sprite_delete(__iesTempSprite);
				__iesTempSprite = sprite_add(_file, 0, false, false, 0, 0);
				__panelCurrentClass.FromSprite(__iesTempSprite);
			}
		}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("Preview:"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCustom(, function(_element) {
			_element.height = 0;
			__panelCurrentClass.__renderize();
		}), _menuA);
		var _previewSurface = _inspector.AddElement(new __Crystal_UIElementSurface(_ref, "__surface", true), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(_previewSurface, "smoothPreview", "Smooth Preview"), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementButton("Save Sprite", function() {
			var _file = get_save_filename("Image Files|*.png;*.jpg;*.jpeg;*.gif", "");
			if (_file != "") {
				var _sprite = __panelCurrentClass.GetSprite();
				sprite_save(_sprite, 0, _file);
			}
		}), _menuA);
	}
	
	
	// Bottom
	// auxiliary panel
	static PanelAux = function() {
		var _inspector = __panelAuxInspector;
		
		var _auxMenuA = _inspector.AddElement(new __Crystal_UIElementSection("UTILITIES", true));
		_inspector.AddElement(new __Crystal_UIElementText("Useful general commands"), _auxMenuA);
		_inspector.AddElement(new __Crystal_UIElementButton("Class Selector", function() {PanelInspect(undefined)}), _auxMenuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _auxMenuA);
			
		_inspector.AddElement(new __Crystal_UIElementText("Not related to Crystal itself, but useful:"), _auxMenuA);
		
		var _roomsMenu = _inspector.AddElement(new __Crystal_UIElementSection("Rooms", false, 2), _auxMenuA);
			auxCurrentRoom = room;
			var _rooms = asset_get_ids(asset_room);
			var _roomsNames = [];
			for (var i = 0; i < array_length(_rooms); ++i) {
				_roomsNames[i] = room_get_name(_rooms[i]);
			}
			_inspector.AddElement(new __Crystal_UIElementRadio(self, "auxCurrentRoom", _roomsNames, _rooms), _roomsMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Go To Selected", function() {
				if (room_exists(auxCurrentRoom)) {
					room_goto(auxCurrentRoom);
				} else {
					__crystal_trace("Room doesn't exists.", 1);
				}
			}), _roomsMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Next Room", function() {
				if (room_next(room) != -1) {
					room_goto_next();
				} else {
					__crystal_trace("Reached last room.", 1);
				}
			}), _roomsMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Previous Room", function() {
				if (room_previous(room) != -1) {
					room_goto_previous();
				} else {
					__crystal_trace("Reached first room.", 1);
				}
			}), _roomsMenu);
		
		var _otherMenu = _inspector.AddElement(new __Crystal_UIElementSection("Other", false, 2), _auxMenuA);
			_inspector.AddElement(new __Crystal_UIElementText("GPU States:"), _otherMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Toggle Tex Filter", call_later, [1, time_source_units_frames, function() {
				// call this after 1 frame because the UI is reseting GPU settings
				gpu_set_tex_filter(!gpu_get_tex_filter());
			}]), _otherMenu);
			_inspector.AddElement(new __Crystal_UIElementButton("Toggle Depth Buffer", call_later, [1, time_source_units_frames, function() {
				// call this after 1 frame because the UI is reseting GPU settings
				var _current = gpu_get_ztestenable();
				var _enable = !_current;
				gpu_set_ztestenable(_enable);
				gpu_set_zwriteenable(_enable);
			}]), _otherMenu);
			//_inspector.AddElement(new __Crystal_UIElementSeparator(), _otherMenu);
			//__currentAppSurfResolution = 1;
			//__currentAppSurfWidth = window_get_width();
			//__currentAppSurfHeight = window_get_height();
			//_inspector.AddElement(new __Crystal_UIElementSlider(self, "__currentAppSurfResolution", "AppSurf Resolution", 0.01, 1), _otherMenu);
			
			//_inspector.AddElement(new __Crystal_UIElementText(,,, function() {
			//	return $"{round(__currentAppSurfWidth*__currentAppSurfResolution)}x{round(__currentAppSurfHeight*__currentAppSurfResolution)}";
			//}), _otherMenu);
			
			//_inspector.AddElement(new __Crystal_UIElementButton("Resize application_surface", call_later, [1, time_source_units_frames, function() {
			//	surface_resize(application_surface, round(__currentAppSurfWidth*__currentAppSurfResolution), round(__currentAppSurfHeight*__currentAppSurfResolution));
			//}]), _otherMenu);
	}
	
	#endregion
	
	#region ============= RIGHT INSPECTORS ==================
	static Inspector = function() {
		__inspectorWindow = new __Crystal_UIWindow("Inspector [Crystal]",, true);
		__inspectorWindow.width = 360;
		__inspectorWindow.xx = window_get_width();
		__inspector = new __Crystal_UIInspector();
		__inspectorWindow.content = __inspector;
		__uiSystem.AddContainer(__inspectorWindow);
	}
	
	// basic light
	static InspectorBasicLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Basic Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementText("sprite_index: ",,, function() {return sprite_get_name(__editorSelectedInstance.sprite_index)}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSprite(__editorSelectedInstance, "sprite_index"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementButton("Select Sprite Asset", function() {
			if (__assetSelector != undefined) __uiSystem.RemoveContainer(__assetSelector);
			__assetSelector = method(self, __interfaces.AssetSelector)( function(_sprite) {__editorSelectedInstance.sprite_index=_sprite; __inspector.__bake();}, asset_sprite );
		}), _menuA);
		spriteImage = -1;
		_inspector.AddElement(new __Crystal_UIElementButton("Load Sprite (Test Only)", function() {
			var _file = get_open_filename("Image Files|*.png;*.jpg;*.jpeg", "");
			if (_file != "") {
				if (sprite_exists(spriteImage)) sprite_delete(spriteImage);
				spriteImage = sprite_add(_file, 0, false, false, 0, 0);
				sprite_set_offset(spriteImage, sprite_get_width(spriteImage)/2, sprite_get_height(spriteImage)/2);
				__editorSelectedInstance.sprite_index = spriteImage;
			}
		}), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "image_blend"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_xscale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_yscale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_angle",, 0, 360, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_alpha",, 0, 1), _menuA);
	}
	
	// point light
	static InspectorPointLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Point Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("shaderType"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shaderType", ["Basic", "Phong", "BRDF"]), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "color"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "inner",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "falloff",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "radius",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "levels",, 1, 256, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "castShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "selfShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "penetration",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowPenumbra",, 0, 50), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowUmbra",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowScattering",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowDepthOffset",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "normalDistance",, 0, 150), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "diffuse",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "specular",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "reflection",, 0, 1), _menuA);
			var _litTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("litType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "litType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _litTypeMenu);
			var _shadowLitTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("shadowLitType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shadowLitType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _shadowLitTypeMenu);
	}
	
	// spot light
	static InspectorSpotLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Spot Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("shaderType"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shaderType", ["Basic", "Phong", "BRDF"]), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "color"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "inner",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "falloff",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "radius",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "levels",, 1, 256, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "angle",, 0, 360, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "width",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "spotFOV",, 0, 180), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "spotSmoothness",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "spotDistance",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "tilt",, 0, 1), _menuA);
		spotCookieImage = -1;
		_inspector.AddElement(new __Crystal_UIElementText("cookieTexture: ", __editorSelectedInstance, "cookieTexture"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementButton("Load Cookie Image (Test Only)", function() {
			var _file = get_open_filename("Image Files|*.png;*.jpg;*.jpeg", "");
			if (_file != "") {
				if (sprite_exists(spotCookieImage)) sprite_delete(spotCookieImage);
				spotCookieImage = sprite_add(_file, 0, false, false, 0, 0);
				__editorSelectedInstance.cookieTexture = sprite_get_texture(spotCookieImage, 0);
			}
		}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "castShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "selfShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "penetration",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowPenumbra",, 0, 50), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowUmbra",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowScattering",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowDepthOffset",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "normalDistance",, 0, 150), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "diffuse",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "specular",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "reflection",, 0, 1), _menuA);
			var _litTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("litType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "litType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _litTypeMenu);
			var _shadowLitTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("shadowLitType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shadowLitType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _shadowLitTypeMenu);
	}
	
	// sprite light
	static InspectorSpriteLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Sprite Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("shaderType"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shaderType", ["Basic", "Phong", "BRDF"]), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("sprite_index: ",,, function() {return sprite_get_name(__editorSelectedInstance.sprite_index)}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSprite(__editorSelectedInstance, "sprite_index"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementButton("Select Sprite Asset", function() {
			if (__assetSelector != undefined) __uiSystem.RemoveContainer(__assetSelector);
			__assetSelector = method(self, __interfaces.AssetSelector)( function(_sprite) {__editorSelectedInstance.sprite_index=_sprite; __inspector.__bake();}, asset_sprite );
		}), _menuA);
		spriteImage = -1;
		_inspector.AddElement(new __Crystal_UIElementButton("Load Sprite (Test Only)", function() {
			var _file = get_open_filename("Image Files|*.png;*.jpg;*.jpeg", "");
			if (_file != "") {
				if (sprite_exists(spriteImage)) sprite_delete(spriteImage);
				spriteImage = sprite_add(_file, 0, false, false, 0, 0);
				sprite_set_offset(spriteImage, sprite_get_width(spriteImage)/2, sprite_get_height(spriteImage)/2);
				__editorSelectedInstance.sprite_index = spriteImage;
			}
		}), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "image_blend"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_xscale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_yscale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_angle",, 0, 360, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "image_alpha",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "castShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "selfShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "penetration",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowPenumbra",, 0, 50), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowUmbra",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowScattering",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowDepthOffset",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "normalDistance",, 0, 150), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "diffuse",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "specular",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "reflection",, 0, 1), _menuA);
			var _litTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("litType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "litType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _litTypeMenu);
			var _shadowLitTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("shadowLitType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shadowLitType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _shadowLitTypeMenu);
	}
	
	// direct light
	static InspectorDirectLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Direct Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("shaderType"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shaderType", ["Basic", "Phong", "BRDF"]), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "color"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "angle",, 0, 360), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "castShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "selfShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "penetration",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowPenumbra",, 0, 50), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowUmbra",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowScattering",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowDepthOffset",, -1000, 1000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "normalDistance",, 0, 15), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "diffuse",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "specular",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "reflection",, 0, 1), _menuA);
			var _litTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("litType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "litType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _litTypeMenu);
			var _shadowLitTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("shadowLitType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shadowLitType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _shadowLitTypeMenu);
	}
	
	// shape light
	static InspectorShapeLight = function() {
		var _inspector = __inspector;
		_inspector.RemoveElements();
		
		var _menuA = _inspector.AddElement(new __Crystal_UIElementSection("Shape Light", true));
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"\"{object_get_name(__editorSelectedInstance.object_index)}\" ({__editorSelectedInstance})";}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText(,,,function() {return $"x: {__editorSelectedInstance.x}, y: {__editorSelectedInstance.y}";}), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementSeparator(), _menuA);
		
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "enabled"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "depth",, -15000, 15000, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("shaderType"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shaderType", ["Basic", "Phong", "BRDF"]), _menuA);
		_inspector.AddElement(new __Crystal_UIElementText("path: ",,, function() {return (__editorSelectedInstance.path != undefined) ? path_get_name(__editorSelectedInstance.path) : string(__editorSelectedInstance.path);}), _menuA);
		_inspector.AddElement(new __Crystal_UIElementButton("Select Path Asset", method(self, __interfaces.AssetSelector), [method(self, function(_path) {__editorSelectedInstance.path=_path; __inspector.__bake();}), asset_path]), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "cornerPrecision",, 0, 15, 1), _menuA);
			var _colorMenu = _inspector.AddElement(new __Crystal_UIElementSection("Color", false, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementText("Inner"), _colorMenu);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "color"), _colorMenu);
			_inspector.AddElement(new __Crystal_UIElementText("Outer"), _colorMenu);
			_inspector.AddElement(new __Crystal_UIElementColor(__editorSelectedInstance, "colorOuter"), _colorMenu);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "intensity",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "inner",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "falloff",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "radius",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "levels",, 1, 256, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "angle",, 0, 360, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "xScale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "yScale",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "castShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementCheckbox(__editorSelectedInstance, "selfShadows"), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "penetration",, 0, 5), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowPenumbra",, 0, 50), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowUmbra",, 0, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowScattering",, 0, 1000), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "shadowDepthOffset",, -1, 1, 1), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "normalDistance",, 0, 150), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "diffuse",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "specular",, 0, 10), _menuA);
		_inspector.AddElement(new __Crystal_UIElementSlider(__editorSelectedInstance, "reflection",, 0, 1), _menuA);
			var _litTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("litType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "litType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _litTypeMenu);
			var _shadowLitTypeMenu = _inspector.AddElement(new __Crystal_UIElementSection("shadowLitType", true, 2), _menuA);
			_inspector.AddElement(new __Crystal_UIElementRadio(__editorSelectedInstance, "shadowLitType", ["Always", "LessEqual", "Less", "GreaterEqual", "Greater", "NotEqual", "Equal"], [LIT_ALWAYS, LIT_LESS_EQUAL, LIT_LESS, LIT_GREATER_EQUAL, LIT_GREATER, LIT_NOT_EQUAL, LIT_EQUAL]), _shadowLitTypeMenu);
	}
	#endregion
	
	#region ================== OTHER ========================
	// Asset selector. "callback" is the method to be executed when clicking on an asset. It receives an sprite for the first parameter.
	static AssetSelector = function(_callback, _assetType=asset_sprite) {
		// can be created from the sprite function
		var _window = new __Crystal_UIWindow("Asset Select",, true);
		_window.width = 300;
		_window.height = 400;
		_window.xx = window_get_width()/2-_window.width/2;
		_window.yy = 50;
		
		var _inspector = new __Crystal_UIInspector();
		_inspector.paddingLeft = 5;
		_inspector.paddingTop = 5;
		
		var _assetManagerElement = _inspector.AddElement(new __Crystal_UIElementCustom(, function(_element, _ui) {
			var _assetType = _element.assetType;
			var _assetsArray = asset_get_ids(_assetType);
			var i = 0, isize = array_length(_assetsArray), _asset = undefined;
			var _xOrigin = _element.xx;
			var _yOrigin = _element.yy;
			var _xx = _xOrigin;
			var _yy = _yOrigin;
			var _ww = _element.width;
			var _ml = _ui.__inputLeft;
			var _mlr = _ui.__inputLeftReleased;
			var _mx = _ui.__inputCursorX;
			var _my = _ui.__inputCursorY;
			
			for (var i = 0; i < isize; ++i) {
				_asset = _assetsArray[i];
				
				// Select
				var _selected = false;
				var _color = c_white;
				
				// Sprites
				if (_assetType == asset_sprite) {
					// only draw bitmap sprites
					if (sprite_get_info(_asset).type == 0) {
						if (point_in_rectangle(_mx, _my, _xx, _yy, _xx+32, _yy+32)) {
							if (_ml) _color = c_red;
							_selected = true;
						}
						draw_sprite_stretched_ext(_asset, 0, _xx, _yy, 32, 32, _color, 1);
						// wrap
						_xx += 34;
						if (_xx >= _element.width-24) {
							_xx = _xOrigin;
							_yy += 34;
						}
					} else {
						continue;
					}
				} else
				// Paths
				if (_assetType == asset_path) {
					if (point_in_rectangle(_mx, _my, _xx, _yy, _xx+_ww, _yy+26)) {
						if (_ml) _color = c_red;
						_selected = true;
					}
					draw_set_color(_color);
					draw_text(_xx, _yy, path_get_name(_asset));
					_yy += 28;
				}
				
				// Selected
				if (_selected && _mlr) {
					// call callback function and send the asset to it
					if (_element.callback != undefined) _element.callback(_asset);
				}
			}
			draw_set_color(c_white);
			
			_element.height = _yy - _element.yy;
		}));
		
		// send origin and variable name to the element
		_assetManagerElement.callback = _callback;
		_assetManagerElement.assetType = _assetType;
		// add container to ui system
		_window.content = _inspector;
		__uiSystem.AddContainer(_window);
		// returns window container, so we can remove/destroy this window manually later
		return _window;
	}
	
	#endregion
}

#endregion

#region DEBUG UI

/// @desc Create a Debug UI to monitor, inspect, edit in-game lights and other cool features. Use .Draw() in Post-Draw (recommended) or Draw GUI to visualize the UI.
/// @func Crystal_DebugUI(classInstance)
/// @param {Id.Instance} origin The origin instance to find Crystal constructors to inspect.
/// @param {Struct} classInstance The system struct returned from a constructor/class. Let it blank/undefined if you want the Debug UI to search it for you, in the current object/context.
/// @param {Bool} isOpened If true, the UI starts opened.
/// @param {Bool} startMaximized Windows will appear maximized.
function Crystal_DebugUI(_origin=undefined, _classInstance=undefined, _isOpened=false, _startMaximized=true) constructor {
	static __interfaces = new __Crystal_DebugInterfaces();
	
	// Base
	__overlayRenderables = ds_list_create(); // array with functions
	__uiSystem = new __Crystal_UISystem();
	__editorShowLightsOverlays = true;
	__editorIsEditingLights = false;
	__editorLightRadio = 0;
	__editorIsEnabled = false;
	__editorSelectedInstance = noone;
	//__uiSystem.__debug = true;
	__origin = _origin;
	__startMaximized = _startMaximized;
	
	// UI Items
	// Panel [Left]
	// 2 inspectors (top + bottom)
	__panelWindow = new __Crystal_UIWindow("Crystal Lighting Engine v1.0");
	__panelWindow.isOpened = _isOpened;
	__panelWindow.minWidth = 250;
	__panelWindow.maxWidth = 1000;
	__panelWindow.width = 465;
	__panelFlexbox = new __Crystal_UIFlexbox();
	__panelFlexbox.flexDirection = 0;
	__panelInspector = new __Crystal_UIInspector();
	__panelInspector.width = 0.65;
	//__panelInspector.height = 0.65;
	__panelAuxInspector = new __Crystal_UIInspector();
	__panelAuxInspector.width = 0.35;
	//__panelAuxInspector.height = 0.35;
	__panelFlexbox.AddContainer(__panelAuxInspector);
	__panelFlexbox.AddContainer(__panelInspector);
	__panelWindow.content = __panelFlexbox;
	__panelCurrentClass = undefined;
	__assetSelector = undefined;
	// add items (self scoped)
	PanelInspect(_classInstance);
	method(self, __interfaces.PanelAux)();
	
	// Inspector [Right]
	// 1 inspector
	__inspectorWindow = undefined;
	__inspector = undefined;
	
	// Add to UI system
	__uiSystem.AddContainer(__panelWindow);
	// maximize after 5 frames
	if (__startMaximized) {
		call_later(5, time_source_units_frames, function() {
			__panelWindow.Maximize();
		});
	}
	
	__mouseX = 0;
	__mouseY = 0;
	__timeSource = time_source_create(time_source_game, 1, time_source_units_frames, function() {
		// we're doing this here because getting these values inside Post-Draw event messes with this
		__mouseX = mouse_x;
		__mouseY = mouse_y;
	}, [], -1);
	time_source_start(__timeSource);
	
	#region Private Methods
	
	/// @ignore
	static PanelInspect = function(_class) {
		__panelCurrentClass = _class;
		if (_class == undefined) {
			__crystal_trace("DEBUG: Class Selector", 2);
			method(self, __interfaces.PanelClassSelector)();
		} else {
			// open class if there is a inspector for it, based on class name:
			var _name = instanceof(_class);
			switch(_name) {
				case "Crystal_Renderer": method(self, __interfaces.PanelClassCrystalRenderer)(); break;
				case "Crystal_MaterialLayer": method(self, __interfaces.PanelClassMaterialLayer)(); break;
				case "Crystal_LayerFXNormalFromLuminance": method(self, __interfaces.PanelClassLayerFXNormalFromLuminance)(); break;
				case "Crystal_TimeCycle": method(self, __interfaces.PanelClassTimeCycle)(); break;
				case "Crystal_Cookie": method(self, __interfaces.PanelClassCookie)(); break;
				default:
					__crystal_trace($"DEBUG: There is no UI for the selected item: {_name}", 1);
					break;
			}
		}
	}
	
	#endregion
	
	#region Public Methods
	
	/// @desc Draw debug UI with all windows and other stuff.
	/// @func Draw(font)
	/// @param {real} font The font to use, for drawing texts.
	static Draw = function(_font=__cle_fntDebugUI) {
		// check if it's in a wrong event
		if (event_number != ev_draw_post && event_number != ev_gui && event_number != ev_gui_begin && event_number != ev_gui_end) {
			__crystal_trace("Debug UI can only be drawn in Post-Draw or GUI events.", 1);
			exit;
		}
		
		// Draw Debug
		// Overlays (below UI)
		var _overlayRenderablesSize = ds_list_size(__overlayRenderables);
		if (_overlayRenderablesSize > 0) {
			var _crossX = __mouseX;
			var _crossY = __mouseY;
			var _cam = view_get_camera(0);
			var _proj = matrix_get(matrix_projection);
			var _view = matrix_get(matrix_view);
			camera_apply(_cam);
			for (var i = 0; i < _overlayRenderablesSize; ++i) {
				__overlayRenderables[| i]();
			}
			// draw cross
			if (__editorIsEditingLights) {
				var _radius = 8;
				draw_line(_crossX-_radius, _crossY, _crossX+_radius, _crossY);
				draw_line(_crossX, _crossY-_radius, _crossX, _crossY+_radius);
			}
			matrix_set(matrix_projection, _proj);
			matrix_set(matrix_view, _view);
			// reset list (after drawing)
			ds_list_clear(__overlayRenderables);
		}
		
		// Draw ui items
		var _oldFont = draw_get_font(),
			_oldColor = draw_get_color(),
			_oldZwrite = gpu_get_zwriteenable(),
			_oldZtest = gpu_get_ztestenable(),
			_oldAlphaTest = gpu_get_alphatestenable(),
			_oldCulling = gpu_get_cullmode(),
			_oldTexFilter = gpu_get_tex_filter();
		draw_set_font(_font);
		draw_set_color(c_white);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(false);
		gpu_set_cullmode(cull_noculling);
		gpu_set_tex_filter(false);
			__uiSystem.Draw();
		draw_set_font(_oldFont);
		draw_set_color(_oldColor);
		gpu_set_zwriteenable(_oldZwrite);
		gpu_set_ztestenable(_oldZtest);
		gpu_set_alphatestenable(_oldAlphaTest);
		gpu_set_cullmode(_oldCulling);
		gpu_set_tex_filter(_oldTexFilter);
		
		// EDITOR (MOVE, ADD ITEMS)
		// I know this is a bad way of doing that ;-;
		if (__editorIsEnabled) {
			// Create inspector automatically when enabling editor, if it doesn't exists
			if (__inspectorWindow == undefined) {
				method(self, __interfaces.Inspector)();
				if (__startMaximized) {
					call_later(2, time_source_units_frames, function() {
						__inspectorWindow.Maximize();
					});
				}
			} else {
				// If mouse is OUTSIDE UI (not clicking on an container), you CAN PLACE lights
				if (__uiSystem.__containerInFocus == undefined) {
					if (__editorIsEditingLights) {
						// check for collision with mouse
						var _mouseHover = false;
						if (__uiSystem.__inputLeftPressed || __uiSystem.__inputRightPressed) {
							var _priority = ds_priority_create();
							var _objectsToCheck = [__cle_objLightStatic, __cle_objLightDynamic];
							for(var o = 0; o < array_length(_objectsToCheck); ++o) {
								var _nearest = instance_nearest(__mouseX, __mouseY, _objectsToCheck[o]);
								if (_nearest != noone) {
									ds_priority_add(_priority, _nearest, point_distance(__mouseX, __mouseY, _nearest.x, _nearest.y));
								}
							}
							var _near = ds_priority_find_min(_priority);
							if (_near != undefined) {
								_mouseHover = point_distance(__mouseX, __mouseY, _near.x, _near.y) < 8;
								if (_mouseHover) __editorSelectedInstance = _near;
							}
							ds_priority_destroy(_priority);
						}
						if (__uiSystem.__inputLeftPressed) {
							// create
							if (!_mouseHover) {
								var _object = undefined;
								switch(__editorLightRadio) {
									case 0: _object = __cle_objBasicLight; break;
									case 1: _object = __cle_objSpriteLight; break;
									case 2: _object = __cle_objPointLight; break;
									case 3: _object = __cle_objSpotLight; break;
									case 4: _object = __cle_objShapeLight; break;
									case 5: _object = __cle_objDirectLight; break;
								}
								if (_object != undefined) {
									instance_create_depth(__mouseX, __mouseY, -15000, _object);
								}
							} else {
								// select
								try {
									var _lightObject = __cle_object_get_root_parent_nth(__editorSelectedInstance.object_index, 1);
									var _inspectorFunction = undefined;
									switch(_lightObject) {
										case __cle_objBasicLight: _inspectorFunction = __interfaces.InspectorBasicLight; break;
										case __cle_objPointLight: _inspectorFunction = __interfaces.InspectorPointLight; break;
										case __cle_objSpotLight: _inspectorFunction = __interfaces.InspectorSpotLight; break;
										case __cle_objSpriteLight: _inspectorFunction = __interfaces.InspectorSpriteLight; break;
										case __cle_objDirectLight: _inspectorFunction = __interfaces.InspectorDirectLight; break;
										case __cle_objShapeLight: _inspectorFunction = __interfaces.InspectorShapeLight; break;
										default:
											__inspector.RemoveElements();
											__crystal_trace($"\"{object_get_name(_lightObject.object_index)}\" has no inspector.", 1);
											break;
									}
									if (_inspectorFunction != undefined) {
										method(self, _inspectorFunction)();
									}
								} catch(_error) {
									__crystal_trace($"Failed to select. {_error.message}", 1);
								}
							}
						}
						
						// Move
						if (__uiSystem.__inputLeft) {
							if (__editorSelectedInstance != noone) {
								__editorSelectedInstance.x += __uiSystem.__inputCursorDXR;
								__editorSelectedInstance.y += __uiSystem.__inputCursorDYR;
								__inspector.__bake();
							}
						}
									
						// Delete
						if (__uiSystem.__inputRightPressed) {
							if (_mouseHover) {
								if (__editorSelectedInstance != noone) instance_destroy(__editorSelectedInstance);
							} else {
								// or clear inspector
								__inspector.RemoveElements();
							}
						}
					}
				}
				// Auto clean inspector if instance was deleted
				if (!instance_exists(__editorSelectedInstance)) {
					__inspector.RemoveElements();
					__editorSelectedInstance = noone;
				}
			}
		} else {
			// Destroy inspector window if disable editor
			if (__inspectorWindow != undefined) {
				__uiSystem.RemoveContainer(__inspectorWindow);
				__inspectorWindow = undefined;
			}
		}
	}
	
	/// @desc Destroy debug UI.
	/// @func Destroy()
	static Destroy = function() {
		// destroy everything, including children
		__uiSystem.Destroy();
		ds_list_destroy(__overlayRenderables);
		time_source_destroy(__timeSource);
	}
	
	#endregion
	
}
#endregion

/// @desc Show Crystal's Debug UI.
/// @param {Bool} show If true, the UI will be created. If false, the existing UI will be destroyed.
/// @param {Id.Instance} originInstance The origin instance to find Crystal constructors to inspect. Example: id, to find from self instance.
/// @param {Struct} classInstance The struct returned from a constructor/class. Let it blank/undefined if you want the Debug UI to search it for you, in the current object/context.
/// @param {Bool} isOpened If true, the UI starts opened.
/// @param {Bool} startMaximized Windows will appear maximized.
function crystal_debug_show(_show, _originInstance=undefined, _classInstance=undefined, _isOpened=true, _startMaximized=true) {
	if (_show) {
		if (instance_exists(__cle_objDebugUI)) exit;
		var _debugUIInst = instance_create_depth(0, 0, -15990, __cle_objDebugUI, {
			origin : _originInstance,
			classInstance : _classInstance,
			isOpened : _isOpened,
			__startMaximized : _startMaximized
		});
		return _debugUIInst;
	} else {
		instance_destroy(__cle_objDebugUI);
	}
}
