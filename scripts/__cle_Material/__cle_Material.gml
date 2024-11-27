
// Feather ignore all

/// @desc A material refers to the properties of an object's surface.
/// Note that this is optional, you will only need materials if you want to achieve the following effects: Normal Map, Emissive, Unlit, Metallic, Roughness, Ambient Occlusion, Reflections and Light Mask.
/// 
/// Call .Apply() and this material will be added to the last renderer, unless you use crystal_set_renderer() to override.
/// This will add realism to the images if PBR is enabled.
/// @param {Id.Instance,Struct} owner The instance to get default properties. Use noone if you want multiple materials (not ideal, because you should use a single material per instance).
/// @param {Bool} isBitmap true means bitmap sprites (default). Set to false if using skeleton sprites from Spine.
function Crystal_Material(_owner, _isBitmap=true) constructor {
	static defaultOwner = {depth : 0, x : 0, y : 0, image_angle : 0, image_xscale : 1, image_yscale : 1};
	if (!instance_exists(_owner)) {
		_owner = defaultOwner;
	}
	// base
	__cull = false;
	__destroyed = false;
	__applied = false;
	
	// properties
	isBitmap = _isBitmap;
	enabled = true;
	self.depth = _owner.depth;
	self.x = _owner.x;
	self.y = _owner.y;
	xScale = _owner.image_xscale;
	yScale = _owner.image_yscale;
	angle = _owner.image_angle;
	normalSprite = undefined;
	normalSpriteSubimg = 0;
	normalIntensity = 1;
	metallicSprite = undefined;
	metallicSpriteSubimg = 0;
	metallicIntensity = 1;
	roughnessSprite = undefined;
	roughnessSpriteSubimg = 0;
	roughnessIntensity = 1;
	aoSprite = undefined;
	aoSpriteSubimg = 0;
	aoIntensity = 1;
	emissiveSprite = undefined;
	emissiveSpriteSubimg = 0;
	emissionColor = c_white;
	emissionIntensity = 1;
	reflectionSprite = undefined;
	reflectionSpriteSubimg = 0;
	reflectionColor = c_white;
	reflectionXscale = 1;
	reflectionYscale = 1;
	reflectionIntensity = 1;
	maskSprite = undefined;
	maskSpriteSubimg = 0;
	maskIntensity = 1;
	// Spine skeleton related (if in use)
	animName = "";
	skinName = "default";
	animTime = 0;
	
	#region Public Methods
	
	/// @desc Destroys the material from the Crystal_Renderer(). You should call this when the instance is destroyed, for example. Useful for the Clean-Up Event.
	/// You can call .Apply() again after calling this function, and the material will be sent to the renderer again.
	/// @method Destroy()
	static Destroy = function() {
		__destroyed = true;
		__applied = false;
		return self;
	}
	
	/// @desc Call this after setting up the material and it will be sent to Crystal_Renderer().
	/// @param {Struct.Crystal_Renderer} renderer The renderer to add the material for rendering. If not specified, adds to the last created renderer (or set with crystal_set_renderer()).
	/// @method Apply(renderer)
	static Apply = function(_renderer=global.__CrystalCurrentRenderer) {
		// if already applied, do nothing.
		if (__applied) {
			__crystal_trace("Material not applied, material already rendering!", 1);
			return;
		}
		// check if renderer exists
		if (_renderer == undefined) {
			__crystal_trace("Material not created, renderer not found. (creation order?)", 1);
			return;
		}
		// add to renderer (once)
		_renderer.__addMaterial(self);
		__applied = true;
		__destroyed = false;
	}
	
	/// @desc With this function, it is possible to synchronize the frame of all material sprites (bitmap only) with the specified value. Useful for animated PBR objects.
	/// 
	/// Note that you assume that the frame sequence of the associated sprites is synchronized to the same frame index. 
	/// @method SyncFrame(frame)
	/// @param {Real} frame The image index/frame to sync. Example: image_index.
	static SyncFrame = function(_frame) {
		normalSpriteSubimg = _frame;
		metallicSpriteSubimg = _frame;
		roughnessSpriteSubimg = _frame;
		aoSpriteSubimg = _frame;
		emissiveSpriteSubimg = _frame;
		reflectionSpriteSubimg = _frame;
		maskSpriteSubimg = _frame;
	}
	
	/// @desc This function will synchronize the drawing of the Spine skeleton animation with the animation of the current context instance. Only useful for Spine skeleton sprites. You can also use "animName" and "skinName" variables for this.
	/// @method SyncAnimation(animation, skin)
	/// @param {String} animation The Spine sprite animation name.
	/// @param {String} skin The Spine sprite skin name.
	static SyncAnimation = function(_animation, _skin) {
		animName = _animation;
		skinName = _skin;
	}
	
	/// @desc This function synchronizes the Spine skeleton animation frame with the current context instance. If you want to have control over the normalized position (0-1) of the animation, use "animTime" variable directly from the material.
	/// @method SyncAnimationTime(position, duration)
	/// @param {Real} position The animation position. You can use skeleton_animation_get_position(0).
	/// @param {Real} duration The animation duration. You can use skeleton_animation_get_duration();
	static SyncAnimationTime = function(_position, _duration) {
		animTime = _position * _duration;
	}
	
	/// @desc Returns a boolean indicating whether the material is already applied (.Apply() was called).
	/// @method IsApplied()
	static IsApplied = function() {
		return __applied;
	}
	
	#endregion
}
