
/// Feather ignore all

/// @desc This constructor aims to add an alpha channel to materials, including normal maps, based on the alpha channel of the albedo, or of a specific sprite for mask (black and white).
/// This is useful for pre-calculating the alpha channel before using the material sprites in the game, reducing overdraw and dramatically increasing performance.
/// This is optional, you can also draw the materials already with alpha channel. This can be more useful if you export animations from Blender without alpha channel, for example.
function Crystal_AlphaBaker() constructor {
	// base
	__inputPath = "";
	__outputPath = "";
	
	/// @desc Define the folder to search for image files.
	/// @method SetInputFolder(folderPath)
	/// @param {String} folderPath The folder path to search for files.
	static SetInputFolder = function(_folderPath) {
		if (!directory_exists(_folderPath)) {
			__crystal_trace("AlphaBaker: input folder not found", 2);
			exit;
		}
		__inputPath = _folderPath;
	}
	
	/// @desc Define the folder to save all modified sprites.
	/// @method SetOutputFolder(folderPath)
	/// @param {String} folderPath The folder path to save generated image files.
	static SetOutputFolder = function(_folderPath) {
		if (!directory_exists(_folderPath)) {
			__crystal_trace("AlphaBaker: output folder not found", 2);
			exit;
		}
		__outputPath = _folderPath;
	}
	
	/// @desc Search for files (in the input folder), bake alpha into them and export them to the output folder.
	/// 
	/// This function will search for files that have the codenames (upper or lower case - it doesn't matter): "mask" (Black&White), "albedo" (Default sprite with alpha) "normal/normals/nml" (NormalMap), "metallic", "roughness/specular", "ao" (Ambient Occlusion).
	/// 
	/// IMPORTANT:
	/// The INPUT folder MUST contain several other folders containing all respective material sprites. Example: Input > Sprite1 > albedo.png, normal.png | Input > Sprite2 > albedo.png, normal.png ...
	/// The file names don't matter, the script just needs to detect the words "normal", "ao", etc. Writing the name "albedo" is optional. Note that when having "albedo" and "mask" in the same folder, the "mask" sprite takes priority.
	/// If there is an "albedo" sprite in the folder, the alpha channel of that sprite will be used as the alpha channel for the materials.
	/// If there is a "mask" sprite in the folder, the "albedo" is ignored and black colors will clip the alpha channel and white colors will keep the pixels opaque.
	/// Animated sprites MUST be in strip format (horizontal sequence). .gif images only support the first frame (GM limitation).
	/// @method Bake()
	static Bake = function() {
		if (__inputPath == "") {
			__crystal_trace("AlphaBaker: no input folder defined, failed to bake", 2);
			exit;
		}
		if (__outputPath == "") {
			__crystal_trace("AlphaBaker: no output folder defined, failed to bake", 2);
			exit;
		}
		
		// Search for files or folders in the folder
		__crystal_trace("AlphaBaker: searching sprite folders", 2);
		var _contents = []; // array with structs
		
		// find folders
		var f = 0, _folderName = file_find_first(__inputPath + "*.*", fa_directory);
		while(_folderName != "") {
			_contents[f] = {
				folder : _folderName,
				//frames : 1, // UNUSED
				albedo : undefined,
				mask : undefined,
				normal : undefined,
				metallic : undefined,
				roughness : undefined,
				ao : undefined,
				emissive : undefined,
			};
			//if (string_count("strip", _folderName) > 0) {
			//	var _aa = string_last_pos("strip", _folderName);
			//	var _bb = string_copy(_folderName, _aa, string_length(_folderName));
			//	_contents[f].frames = real(string_digits(_bb));
			//}
			_folderName = file_find_next();
			f++;
		}
		file_find_close();
		
		// search inside folder
		var fsize = f;
		f = 0;
		repeat(fsize) {
			var _item = _contents[f];
			var _insideFolderName = _item.folder;
			var s = 0;
			var _fileName = file_find_first(__inputPath + "/" + _insideFolderName + "/*.*", fa_archive);
			while(_fileName != "") {
				//show_debug_message(_fileName);
				var _fileExtension = filename_ext(_fileName);
				if (_fileExtension == "*.gif" || _fileExtension == ".png" || _fileExtension == ".jpg" || _fileExtension == ".jpeg") {
					var _materialName = string_lower(_fileName);
					if (string_pos("mask", _materialName) > 0) {
						_item.mask = _materialName;
					} else
					if (string_pos("normal", _materialName) > 0 || string_pos("nml", _materialName) > 0) {
						_item.normal = _materialName;
					} else
					if (string_pos("metallic", _materialName) > 0) {
						_item.metallic = _materialName;
					} else
					if (string_pos("roughness", _materialName) > 0 || string_count("specular", _materialName) > 0) {
						_item.roughness = _materialName;
					} else
					if (string_pos("ao", _materialName) > 0 || string_pos("occlusion", _materialName) > 0) {
						_item.ao = _materialName;
					} else
					if (string_pos("emissive", _materialName) > 0) {
						_item.emissive = _materialName;
					} else
					if (string_pos("albedo", _materialName) > 0) {
						_item.albedo = _materialName;
					} else {
						_item.albedo = _materialName;
					}
				}
				_fileName = file_find_next();
				++s;
			}
			file_find_close();
			f++;
		}
		// ------------------------
		
		// Process contents found
		var _u_color = shader_get_uniform(__cle_shAlphaBakeThreshold, "u_color");
		var _u_threshold = shader_get_uniform(__cle_shAlphaBakeThreshold, "u_threshold");
		var _albedoSprite=undefined, _maskSprite=undefined, _normalSprite=undefined, _metallicSprite=undefined, _roughnessSprite=undefined, _aoSprite=undefined, _emissiveSprite=undefined;
		var _normalSurf=undefined, _metallicSurf=undefined, _roughnessSurf=undefined, _aoSurf=undefined, _emissiveSurf=undefined;
		for (var i = 0; i < array_length(_contents); ++i) {
			var _item = _contents[i];
			var _folder = _item.folder;
			var _frames = 1;//_item.frames; // UNUSED
			var _inputPath = __inputPath + "/" + _folder + "/";
			var _outputPath = __outputPath + "/" + _folder + "/";
			__crystal_trace(_folder, 2);
			
			// albedo
			_albedoSprite = undefined;
			_maskSprite = undefined;
			var _albedo = _item.albedo;
			var _mask = _item.mask;
			if (_mask != undefined) {
				_maskSprite = sprite_add(_inputPath+_mask, _frames, false, false, 0, 0);
			} else {
				if (_albedo != undefined) {
					_albedoSprite = sprite_add(_inputPath+_albedo, _frames, false, false, 0, 0);
				}
			}
			if (_albedo == undefined && _mask == undefined) {
				__crystal_trace("Failed to bake: albedo or mask is required");
				continue;
			}
			
			gpu_push_state();
			
			//gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
			// normal
			var _normal = _item.normal;
			if (_normal != undefined) {
				_normalSprite = sprite_add(_inputPath+_normal, _frames, false, false, 0, 0);
				_normalSurf = surface_create(sprite_get_width(_normalSprite), sprite_get_height(_normalSprite), surface_rgba8unorm);
				surface_set_target(_normalSurf);
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					// write albedo and mask to alpha channel
					gpu_set_colorwriteenable(false, false, false, true);
					if (_albedoSprite != undefined) {
						draw_sprite(_albedoSprite, 0, 0, 0);
					}
					if (_maskSprite != undefined) {
						shader_set(__cle_shWriteToAlpha);
						draw_sprite(_maskSprite, 0, 0, 0);
						shader_reset();
					}					
					// write to RGB only (without masks, the output image will be black! since alpha is 0)
					gpu_set_colorwriteenable(true, true, true, false);
					draw_sprite(_normalSprite, 0, 0, 0);
					gpu_set_colorwriteenable(true, true, true, true);
				surface_reset_target();
				surface_save(_normalSurf, _outputPath+_normal);
				surface_free(_normalSurf);
				sprite_delete(_normalSprite);
			}
			
			// metallic
			var _metallic = _item.metallic;
			if (_metallic != undefined) {
				_metallicSprite = sprite_add(_inputPath+_metallic, _frames, false, false, 0, 0);
				_metallicSurf = surface_create(sprite_get_width(_metallicSprite), sprite_get_height(_metallicSprite), surface_rgba8unorm);
				surface_set_target(_metallicSurf);
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					// write albedo and mask to alpha channel
					gpu_set_colorwriteenable(false, false, false, true);
					if (_albedoSprite != undefined) {
						draw_sprite(_albedoSprite, 0, 0, 0);
					}
					if (_maskSprite != undefined) {
						shader_set(__cle_shWriteToAlpha);
						draw_sprite(_maskSprite, 0, 0, 0);
						shader_reset();
					}					
					// write to RGB only (without masks, the output image will be black! since alpha is 0)
					gpu_set_colorwriteenable(true, true, true, false);
					draw_sprite(_metallicSprite, 0, 0, 0);
					gpu_set_colorwriteenable(true, true, true, true);
				surface_reset_target();
				surface_save(_metallicSurf, _outputPath+_metallic);
				surface_free(_metallicSurf);
				sprite_delete(_metallicSprite);
			}
			
			// roughness
			var _roughness = _item.roughness;
			if (_roughness != undefined) {
				_roughnessSprite = sprite_add(_inputPath+_roughness, _frames, false, false, 0, 0);
				_roughnessSurf = surface_create(sprite_get_width(_roughnessSprite), sprite_get_height(_roughnessSprite), surface_rgba8unorm);
				surface_set_target(_roughnessSurf);
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					// write albedo and mask to alpha channel
					gpu_set_colorwriteenable(false, false, false, true);
					if (_albedoSprite != undefined) {
						draw_sprite(_albedoSprite, 0, 0, 0);
					}
					if (_maskSprite != undefined) {
						shader_set(__cle_shWriteToAlpha);
						draw_sprite(_maskSprite, 0, 0, 0);
						shader_reset();
					}					
					// write to RGB only (without masks, the output image will be black! since alpha is 0)
					gpu_set_colorwriteenable(true, true, true, false);
					draw_sprite(_roughnessSprite, 0, 0, 0);
					gpu_set_colorwriteenable(true, true, true, true);
				surface_reset_target();
				surface_save(_roughnessSurf, _outputPath+_roughness);
				surface_free(_roughnessSurf);
				sprite_delete(_roughnessSprite);
			}
			
			// ao
			var _ao = _item.ao;
			if (_ao != undefined) {
				_aoSprite = sprite_add(_inputPath+_ao, _frames, false, false, 0, 0);
				_aoSurf = surface_create(sprite_get_width(_aoSprite), sprite_get_height(_aoSprite), surface_rgba8unorm);
				surface_set_target(_aoSurf);
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					// write albedo and mask to alpha channel
					gpu_set_colorwriteenable(false, false, false, true);
					if (_albedoSprite != undefined) {
						draw_sprite(_albedoSprite, 0, 0, 0);
					}
					if (_maskSprite != undefined) {
						shader_set(__cle_shWriteToAlpha);
						draw_sprite(_maskSprite, 0, 0, 0);
						shader_reset();
					}					
					// write to RGB only (without masks, the output image will be black! since alpha is 0)
					gpu_set_colorwriteenable(true, true, true, false);
					draw_sprite(_aoSprite, 0, 0, 0);
					gpu_set_colorwriteenable(true, true, true, true);
				surface_reset_target();
				surface_save(_aoSurf, _outputPath+_ao);
				surface_free(_aoSurf);
				sprite_delete(_aoSprite);
			}
			
			// emissive
			var _emissive = _item.emissive;
			if (_emissive != undefined) {
				_emissiveSprite = sprite_add(_inputPath+_emissive, _frames, false, false, 0, 0);
				_emissiveSurf = surface_create(sprite_get_width(_emissiveSprite), sprite_get_height(_emissiveSprite), surface_rgba8unorm);
				surface_set_target(_emissiveSurf);
					draw_clear_alpha(c_black, 0);
					gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
					shader_set(__cle_shAlphaBakeThreshold);
					shader_set_uniform_f(_u_color, 0, 0, 0);
					shader_set_uniform_f(_u_threshold, 0.001);
					draw_sprite(_emissiveSprite, 0, 0, 0);
					shader_reset();
				surface_reset_target();
				surface_save(_emissiveSurf, _outputPath+_emissive);
				surface_free(_emissiveSurf);
				sprite_delete(_emissiveSprite);
			}
			gpu_set_blendmode(bm_normal);
			gpu_pop_state();
			
			// free albedo
			if (_albedoSprite != undefined) sprite_delete(_albedoSprite);
			if (_maskSprite != undefined) sprite_delete(_maskSprite);
		}
		
		// finished
		__crystal_trace($"AlphaBaker: Folders processed: {f} ", 2);
	}
}
