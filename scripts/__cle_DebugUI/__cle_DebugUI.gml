
/*========================================================================
	Simple UI System for Debugging.
	Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
	Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
	
	I am aware that focus stuff are very poorly implemented and many stuff
	could be better.
========================================================================*/

/// Feather ignore all
#region Helper Functions
/// @desc Linear interpolation (lerp) remap. Returns the result of a non-clamping linear remapping of a value from source range [_inMin, _inMax] to the destination range [_outMin, _outMax].
/// @param {Real} inMin Input min value.
/// @param {Real} inMax Input max value.
/// @param {Real} value Value to remap.
/// @param {Real} inMin Output min value.
/// @param {Real} inMax Output max value.
/// @ignore
function __cle_ui_relerp(_inMin, _inMax, _value, _outMin, _outMax) {
	return (_value-_inMin) / (_inMax-_inMin) * (_outMax-_outMin) + _outMin;
	//return lerp(_outMin, _outMax, linearstep(_inMin, _inMax, _value));
}

/// @desc Inverse linear interpolation (lerp). Interpolates between a and b, based on value. Returns a value between 0 and 1, representing where the "value" parameter falls within the range defined by a and b.
///
/// Example: var prog = linearstep(20, 40, 22) -> 0.10;
/// @param {Real} a The start of the range.
/// @param {Real} b The end of the range.
/// @param {Real} value The point within the range you want to calculate.
/// @ignore
function __cle_ui_linearstep(_a, _b, _value) {
	return (_value - _a) / (_b - _a);
}

/// @desc Get objects's root parent.
/// @param {Id.GMObject} object The object to get root parent object from.
/// @ignore
function __cle_object_get_root_parent(_object) {
	var _curr = _object, _rootObject = _object;
	while(object_get_parent(_curr) > 0) {
		_curr = object_get_parent(_curr);
		_rootObject = _curr;
	}
	return _rootObject;
}

/// @desc Get objects's root parent.
/// @param {Id.GMObject} object The object to get root parent object from.
/// @param {Real} nth The root offset.
/// @ignore
function __cle_object_get_root_parent_nth(_object, _nth=0) {
	var _curr = _object, _list = [_object], i = 0;
	while(object_get_parent(_curr) > 0) {
		_curr = object_get_parent(_curr);
		_list[++i] = _curr;
	}
	var _size = array_length(_list)-1;
	return _list[max(0, _size-_nth)];
}

/// @desc Convert bytes to KB, MB, GB, etc.
/// @param {real} bytes File bytes amount.
/// @ignore
function __cle_bytes_get_size(_bytes) {
	static _sizes = ["B", "KB", "MB", "GB", "TB", "PB"]; // you can add more
	if (_bytes <= 0) return "0 B";
	var i = floor(log2(_bytes) / log2(1024));
	return string(round(_bytes / power(1024, i))) + " " + _sizes[i];
}
#endregion

// ---------------------
#region UI SYSTEM
/// @desc Creates a UI system. It is responsible for drawing all containers and their children.
/// @ignore
function __Crystal_UISystem() constructor {
	// base
	__currentEvent = -1;
	__containers = [];
	__debug = false;
	__isReady = false;
	__containerReorderStruct = undefined;
	__containerInFocus = undefined;
	__elementInFocus = undefined; // ui element struct
	
	// input & canvas
	__canvasWidth = 0;
	__canvasHeight = 0;
	__inputCursorX = 0; // raw mouse input
	__inputCursorY = 0;
	__inputCursorDX = 0;
	__inputCursorDY = 0;
	__inputCursorDXR = 0;
	__inputCursorDYR = 0;
	__inputLeft = false;
	__inputRight = false;
	__inputMiddle = false;
	__inputLeftPressed = false;
	__inputRightPressed = false;
	__inputMiddlePressed = false;
	__inputLeftReleased = false;
	__inputRightReleased = false;
	__inputMiddleReleased = false;
	__inputOldMouseX = 0;
	__inputOldMouseY = 0;
	__inputOldWindowMouseX = 0;
	__inputOldWindowMouseY = 0;
	__inputOldGUIMouseX = 0;
	__inputOldGUIMouseY = 0;
	
	// step
	__tsStep = call_later(1, time_source_units_frames, function() {
		// Input
		__inputCursorX = 0;
		__inputCursorY = 0;
		__inputLeft = mouse_check_button(mb_left);
		__inputRight = mouse_check_button(mb_right);
		__inputMiddle = mouse_check_button(mb_middle);
		__inputLeftPressed = mouse_check_button_pressed(mb_left);
		__inputRightPressed = mouse_check_button_pressed(mb_right);
		__inputMiddlePressed = mouse_check_button_pressed(mb_middle);
		__inputLeftReleased = mouse_check_button_released(mb_left);
		__inputRightReleased = mouse_check_button_released(mb_right);
		__inputMiddleReleased = mouse_check_button_released(mb_middle);
		if (__currentEvent == ev_draw_post) {
			__canvasWidth = window_get_width();
			__canvasHeight = window_get_height();
			__inputCursorX = window_mouse_get_x();
			__inputCursorY = window_mouse_get_y();
			__inputCursorDX = __inputCursorX - __inputOldWindowMouseX;
			__inputCursorDY = __inputCursorY - __inputOldWindowMouseY;
		} else
		if (__currentEvent == ev_gui || __currentEvent == ev_gui_begin || __currentEvent == ev_gui_end) {
			__canvasWidth = display_get_gui_width();
			__canvasHeight = display_get_gui_height();
			__inputCursorX = device_mouse_x_to_gui(0);
			__inputCursorY = device_mouse_y_to_gui(0);
			__inputCursorDX = __inputCursorX - __inputOldGUIMouseX;
			__inputCursorDY = __inputCursorY - __inputOldGUIMouseY;
		}
		__inputCursorDXR = mouse_x - __inputOldMouseX;
		__inputCursorDYR = mouse_y - __inputOldMouseY;
	}, true);
	__tsEndStep = undefined;
	// end step
	call_later(2, time_source_units_frames, function() {
		__tsEndStep = call_later(1, time_source_units_frames, function() {
			__inputOldGUIMouseX = device_mouse_x_to_gui(0);
			__inputOldGUIMouseY = device_mouse_y_to_gui(0);
			__inputOldWindowMouseX = window_mouse_get_x();
			__inputOldWindowMouseY = window_mouse_get_y();
			__inputOldMouseX = mouse_x;
			__inputOldMouseY = mouse_y;
			__isReady = true;
		}, true);
	}, false);
	
	#region Public Methods
	// Container
	/// @desc Add container for rendering.
	static AddContainer = function(_container) {
		array_push(__containers, _container);
	}
	/// @desc Remove container from rendering.
	static RemoveContainer = function(_container) {
		var _size = array_length(__containers);
		for (var i = 0; i < _size; ++i) {
			if (__containers[i] == _container) {
				// call Destroy() function from container
				// the container MUST be responsible for destroying its children and freeing memory (like surfaces)
				if (_container.Destroy != undefined) _container.Destroy();
				// remove container from list
				array_delete(__containers, i, 1);
				break;
			}
		}
	}
	/// @desc Focus container.
	static FocusContainer = function(_container) {
		if (__containerInFocus == undefined) __containerInFocus = _container;
	}
	/// @desc Find top container (useful for windows containers).
	static FindTopContainer = function(_container) {
		var _size = array_length(__containers);
		for (var i = _size-1; i >= 0; --i) {
			if (__containers[i] == _container) {
				__containerReorderStruct = {oldContainerPosition: i, newContainer: _container};
				return _container;
				break;
			}
		}
	}
	
	// Element
	/// @desc Focus element.
	static FocusElement = function(_element) {
		if (__elementInFocus == undefined) __elementInFocus = _element;
	}
	
	/// @desc Destroy UI system and all containers.
	static Destroy = function() {
		var _size = array_length(__containers), _container = undefined;
		// destroy from last to first container
		for (var i = _size-1; i >= 0; --i) {
			_container = __containers[i];
			if (_container.Destroy != undefined) _container.Destroy();
		}
		if (__tsStep != undefined) call_cancel(__tsStep);
		if (__tsEndStep != undefined) call_cancel(__tsEndStep);
	}
	
	/// @desc This function draws all the UI. Automatically detects the event (Post-Draw or Draw GUI) and adjusts itself on it.
	/// Containers: Inspector,Log > Elements: Text,Sprite,Slider
	///
	/// @method Draw()
	static Draw = function() {
		__currentEvent = event_number;
		if (!__isReady) exit;
		
		// Execute containers Draw method
		var _container = undefined;
		for (var i = 0; i < array_length(__containers); ++i) {
			_container = __containers[i];
			if (_container.Draw != undefined) _container.Draw(self);
		}
		
		// Drawing reorder
		if (__containerReorderStruct != undefined) {
			array_delete(__containers, __containerReorderStruct.oldContainerPosition, 1);
			array_push(__containers, __containerReorderStruct.newContainer);
			FocusContainer(__containerReorderStruct.newContainer);
			__containerReorderStruct = undefined;
		}
		
		// Debug
		if (__debug && __containerInFocus != undefined) {
			draw_text(10, 10, $"{__containerInFocus.ID} | {instanceof(__containerInFocus)}");
		}
		
		// reset focus
		if (__inputLeftReleased || __inputRightReleased || __inputMiddleReleased) {
			__elementInFocus = undefined;
			__containerInFocus = undefined;
		}
	}
	#endregion
}
#endregion

#region CONTAINER
/// @desc Base container class for everything.
/// @ignore
function __Crystal_UIContainer() constructor {
	ID = irandom(1000);
	xx = 0;
	yy = 0;
	width = 128;
	height = 128;
	paddingLeft = 0;
	paddingRight = 0;
	paddingTop = 0;
	paddingBottom = 0;
	canInteract = true; // unused for now...
	
	static Destroy = undefined;
	static Draw = function(_ui) {
		if (_ui.__debug) {
			var _color = c_lime;
			if (point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
				_color = c_black;
			}
			draw_set_color(_color);
			draw_set_alpha(0.4);
			draw_rectangle(xx, yy, xx+width, yy+height, true);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
	}
}
#endregion

#region FLEXBOX
/// @desc Flexbox works as a layout to automatically adjust containers inside it.
/// @ignore
function __Crystal_UIFlexbox() : __Crystal_UIContainer() constructor {
	// it also contains xx, yy, width and height (like inherited)
	flexDirection = 0; // row, column
	justify = 0; // proportional, stretch
	align = 0; // flex-start, center, flex-end, stretch
	identation = 0;
	spacing = 0;
	children = [];
	
	static AddContainer = function(_container) {
		array_push(children, _container);
	}
	
	static Draw = function(_ui) {
		// debug
		if (_ui.__debug) {
			draw_set_color(c_red);
			draw_set_alpha(0.4);
			draw_rectangle(xx, yy, xx+width, yy+height, true);
			draw_set_color(c_white);
			draw_set_alpha(1);
		}
		
		var _count = array_length(children), _child = undefined;
		
		// get children total bounding box area
		var _totalOriginalWidth = 0;
		var _totalOriginalHeight = 0;
		for(var i = 0; i < _count; ++i) {
			_child = children[i];
			_totalOriginalWidth += _child.width; // sum width
			_totalOriginalHeight += _child.height; // sum height
		}
		
		// adjust children inside this flexbox
		var _availableWidth = width - (paddingLeft + paddingRight);
		var _availableHeight = height - (paddingTop + paddingBottom);
		var _currentX = xx;
		var _currentY = yy;
		for(var i = 0; i < _count; ++i) {
			_child = children[i];
			
			// Proportional
			if (justify == 0) {
				if (flexDirection == 0) {
					// horizontal
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_child.width *= (_availableWidth / _totalOriginalWidth); // scale
					_child.height = _availableHeight;
					_currentX += _child.width;
				} else
				if (flexDirection == 1) {
					// vertical
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_child.width = _availableWidth;
					_child.height *= (_availableHeight / _totalOriginalHeight); // scale
					_currentY += _child.height;
				}
			} else
			
			// Stretch
			if (justify == 1) {
				if (flexDirection == 0) {
					// horizontal
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_child.width = _availableWidth / _count;
					_child.height = _availableHeight;
					_currentX += _child.width;
				} else
				if (flexDirection == 1) {
					// vertical
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_child.width = _availableWidth;
					_child.height = _availableHeight / _count;
					_currentY += _child.height;
				}
			}
			
			// Relative
			if (justify == 2) {
				if (flexDirection == 0) {
					// horizontal
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_currentX += _child.width + identation;
					if (_currentX > xx+width - paddingRight) {
						_currentX = xx;
						_currentY += _child.height + spacing;
					}
				} else
				if (flexDirection == 1) {
					// vertical
					_child.xx = _currentX + paddingLeft;
					_child.yy = _currentY + paddingTop;
					_currentY += _child.height + spacing;
					if (_currentY > yy+height - paddingBottom) {
						_currentY = yy;
						_currentX += _child.width + identation;
					}
				}
			}
			
			if (_child.Draw != undefined) _child.Draw(_ui);
		}
	}
	
	static Destroy = function() {
		// call children's Destroy() function
		var i = 0, isize = array_length(children), _child = undefined;
		repeat(isize) {
			_child = children[i];
			if (_child.Destroy != undefined) _child.Destroy();
			++i;
		}
	}
}
#endregion

#region WINDOW
/// @desc The window is a Container. The purpose of the window is just to move the content (flexboxes + containers + other)
/// @ignore
function __Crystal_UIWindow(_title="Window", _barHeight=24, _isCloseable=false) : __Crystal_UIContainer() constructor {
	// container to draw inside window
	// the window will be used to drag this content with the mouse
	title = _title;
	barHeight = _barHeight;
	content = undefined;
	isOpened = true; // define if can draw content
	isCloseable = _isCloseable;
	width = 200;
	height = 300;
	minWidth = 200;
	minHeight = 64;
	maxWidth = infinity;
	maxHeight = infinity;
	resizeMargin = 16;
	dragFlags = 0;
	dragTop = 1 << 0;
	dragBottom = 1 << 1;
	dragLeft = 1 << 2;
	dragRight = 1 << 3;
	isMoving = false;
	canDrag = false;
	__destroy = false;
	__toggleCheckbox = new __Crystal_UIElementCheckbox(self, "isOpened", "");
	__closeButton = new __Crystal_UIElementButton("X", function() {__destroy = true;});
	__ui = undefined;
	
	static Maximize = function() {
		var _ui = __ui;
		if (_ui != undefined) {
			var _centerX = xx+width/2;
			if (_centerX < _ui.__canvasWidth/2) {
				xx = 20;
				yy = 20;
			} else
			if (_centerX > _ui.__canvasWidth/2) {
				xx = _ui.__canvasWidth - width - 20;
				yy = 20;
			}
			height = _ui.__canvasHeight - 40;
		}
	}
	
	static Draw = function(_ui) {
		__ui = _ui;
		width = clamp(width, minWidth, maxWidth);
		height = clamp(height, minHeight, maxHeight);
		var _width = width;
		var _height = height;
		if (!isOpened) {
			_height = barHeight;
		}
		
		#region Focus
		var _mDeltaX = _ui.__inputCursorDX;
		var _mDeltaY = _ui.__inputCursorDY;
		var _mx = _ui.__inputCursorX;
		var _my = _ui.__inputCursorY;
		if (point_in_rectangle(_mx, _my, xx-resizeMargin, yy-resizeMargin, xx+_width+resizeMargin, yy+_height+resizeMargin)) {
			if (_ui.__inputLeftPressed) {
				_ui.FindTopContainer(self);
			}
			if (isOpened) {
				draw_set_color(c_white);
				if (!point_in_rectangle(_mx, _my, xx, yy, xx+_width, yy+_height)) {
					draw_rectangle(xx-resizeMargin, yy-resizeMargin, xx+_width+resizeMargin, yy+_height+resizeMargin, true);
				}
			}
		}
		var _inFocus = (_ui.__containerInFocus == self);
		if (_inFocus) {
			if (_mx < xx) dragFlags |= dragLeft;
			if (_my < yy) dragFlags |= dragTop;
			if (_mx > xx+_width) dragFlags |= dragRight;
			if (_my > yy+_height) dragFlags |= dragBottom;
			if (_my > yy && _my < yy+barHeight) {
				if (dragFlags == 0) isMoving = true;
			}
		}
		if (_ui.__inputLeftReleased) {
			dragFlags = 0;
			isMoving = false;
		}
		#endregion
		
		// Draw content (container)
		if (isOpened) {
			if (content != undefined) {
				content.xx = xx;
				content.yy = yy + barHeight;
				content.width = _width;
				content.height = _height - barHeight;
				content.Draw(_ui);
			}
		}
		
		#region Draw Border + Title + Buttons
		if (_ui.__debug) {
			draw_set_color(c_yellow);
			draw_set_alpha(0.4);
			draw_rectangle(xx, yy, xx+width, yy+height, true);
			draw_set_alpha(1);
		}
		// dragger
		draw_set_alpha(0.9);
		draw_set_color(c_black);
		draw_rectangle(xx, yy, xx+_width, yy+barHeight, false);
		draw_set_alpha(1);
		draw_set_color(c_white);
		// toggle button
		__toggleCheckbox.xx = xx+10;
		__toggleCheckbox.yy = yy+barHeight/2-8;
		__toggleCheckbox.Draw(_ui);
		// title
		draw_set_valign(fa_middle);
		draw_text(xx+32, yy+barHeight/2, title);
		draw_set_valign(fa_top);
		// close button
		if (isCloseable) {
			__closeButton.xx = xx+_width-32;
			__closeButton.yy = yy;
			__closeButton.height = barHeight;
			__closeButton.Draw(_ui);
		}
		#endregion
		
		#region Move + Resize + Maximize + Close
		// Move it after drawing, to update in the next frame
		if (isMoving) {
			xx += _mDeltaX;
			yy += _mDeltaY;
		} else {
			// corners
			if (isOpened) {
				if (dragFlags & dragLeft) {
					xx += _mDeltaX;
					width -= _mDeltaX;
				}
				if (dragFlags & dragTop) {
					yy += _mDeltaY;
					height -= _mDeltaY;
				}
				if (dragFlags & dragRight) {
					width += _mDeltaX;
				}
				if (dragFlags & dragBottom) {
					height += _mDeltaY;
				}
			}
			if (dragFlags != 0) draw_sprite(__cle_sprDebugUIControl, 0, _mx, _my);
		}
		// Maximize
		if (_inFocus && _ui.__inputLeft && _ui.__inputRightPressed) {
			Maximize(_ui);
		}
		if (_ui.__canvasWidth > 0 && _ui.__canvasHeight > 0) {
			xx = clamp(xx, 20, _ui.__canvasWidth-_width-20);
			yy = clamp(yy, 20, _ui.__canvasHeight-_height-20);
		}
		// Close
		if (__destroy) {
			_ui.RemoveContainer(self);
		}
		#endregion
	}
	
	static Destroy = function() {
		// call content's Destroy() function too
		if (content != undefined) {
			if (content.Destroy != undefined) content.Destroy();
		}
	}
}
#endregion

#region INSPECTOR
/// @desc Inspector container with elements (containers too).
/// @ignore
function __Crystal_UIInspector() : __Crystal_UIContainer() constructor {
	// base
	elements = []; // array of element structs (cther containers)
	surface = -1;
	oldWidth = 0;
	oldHeight = 0;
	bakeTimeBase = 8;
	bakeTime = bakeTimeBase;
	uiYoffset = 0;
	areaHeight = 30;
	scrollbar = new __Crystal_UIElementScrollVertical(self, "uiYoffset", "areaHeight", 0.3);
	// prefs
	identation = 10;
	spacing = 8;
	alpha = 1;
	
	#region Private Methods
	/// @ignore
	static __bake = function() {
		// Bake (renderize) UI again. Call it whenever you want to update the UI
		bakeTime = bakeTimeBase;
	}
	#endregion
	
	#region Public Methods
	/// @desc Draw container.
	static Draw = function(_ui) {
		// limit size
		width = max(width, 1);
		height = max(height, 1);
		
		scrollbar.allowScrolling = false;
		if (point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
			if (_ui.__inputLeftPressed || _ui.__inputRightPressed || _ui.__inputMiddlePressed) {
				_ui.FocusContainer(self);
			}
			scrollbar.allowScrolling = true;
		}
		
		var _inFocus = (_ui.__containerInFocus == self);
		if ((_inFocus && (_ui.__inputLeft || _ui.__inputRight || _ui.__inputMiddle)) || scrollbar.isScrolling) {
			__bake();
		}
		
		// background
		draw_set_color(c_black);
		draw_set_alpha(0.3*alpha);
		draw_rectangle(xx, yy, xx+width, yy+height, false);
		draw_set_color(c_white);
		draw_set_alpha(1);
		
		// scrollbar
		scrollbar.width = scrollbar.isActive ? 8 : 0;
		scrollbar.xx = xx+width-scrollbar.width;
		scrollbar.yy = yy;
		scrollbar.height = height;
		scrollbar.Draw(_ui);
		
		// update surface if size changes
		if (oldWidth != width || oldHeight != height) {
			if (surface_exists(surface)) surface_free(surface);
			oldWidth = width;
			oldHeight = height;
		}
		
		// Draw items
		if (!surface_exists(surface)) {
			surface = surface_create(width+1, height+1);
			__bake();
		}
		
		// Render elements
		bakeTime = max(bakeTime-1, 0);
		if (bakeTime > 0) {
			surface_set_target(surface);
			gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
				draw_clear_alpha(c_black, 0);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// convert mouse coordinates to surface coordinates
				var _inputXNormalized = __cle_ui_linearstep(xx, xx+width, _ui.__inputCursorX);
				var _inputYNormalized = __cle_ui_linearstep(yy, yy+height, _ui.__inputCursorY);
				var _oldInputCursorX = _ui.__inputCursorX;
				var _oldInputCursorY = _ui.__inputCursorY;
				_ui.__inputCursorX = lerp(0, width, _inputXNormalized); // for elements inside surface!
				_ui.__inputCursorY = lerp(0, height, _inputYNormalized);
				// Draw elements
				var _elementsArray = elements,
					_elementsAmount = array_length(_elementsArray),
					_xOffsetArray = array_create(_elementsAmount, 0),
					_xOffset = 0,
					_drawItem = 0,
					_element = undefined;
				
				// reset initial yoffset (height)
				areaHeight = 0;
				for(var i = 0; i < _elementsAmount; i++) {
					_element = _elementsArray[i]; // get current element struct
					
					// Folding
					_xOffset = _xOffsetArray[i];
					// dont draw itens if closed
					if (_drawItem > 0) {
						_drawItem -= 1;
						continue;
					}
					if (_element.isFolder) {
						var _folderAmount = _element.folderAmount;
						_drawItem = _folderAmount * (!real(_element.isOpened));
						// offsets
						var j = i + 1;
						repeat(_folderAmount) {
							_xOffsetArray[j] += identation;
							++j;
						}
					}
					// Draw element if inside inspector area
					_element.alpha = alpha;
					_element.xx = _xOffset + paddingLeft;
					_element.yy = areaHeight + uiYoffset + paddingTop;
					_element.width = width - _element.xx - paddingRight - scrollbar.width;
					if (_element.alwaysVisible || (_element.yy > -_element.height && _element.yy < height+16)) {
						if (_element.Draw != undefined) _element.Draw(_ui);
					}
					// auto-bake if slider is moving alone
					if (_element.isDynamic) __bake();
					
					// increase area height from element height
					areaHeight += _element.height + spacing;
				}
				areaHeight += paddingBottom;
				
				// convert mouse coordinates again
				_ui.__inputCursorX = _oldInputCursorX;
				_ui.__inputCursorY = _oldInputCursorY;
			surface_reset_target();
		}
		
		// Draw
		if (surface_exists(surface)) {
			gpu_set_blendmode_ext(bm_one, bm_inv_src_alpha);
			draw_surface(surface, xx, yy);
			gpu_set_blendmode(bm_normal);
		}
		
		// Border
		draw_set_color(c_white);
		//draw_circle_color(xx, yy+areaHeight+uiYoffset, 4, c_red, c_red, true);
	}
	
	/// @method AddElement(element, parent)
	/// @param {Struct} element Element to add.
	/// @param {Struct} parent Parent element to add this element to.
	static AddElement = function(_element, _parent=undefined) {
		// set current element parent (if any) and add element to parent's children list
		if (_parent != undefined) {
			_element.parent = _parent;
			array_push(_parent.children, _element);
		}
		// increase folder amount (if is folder) until root element (folder)
		var _curr = _element;
		while(_curr.parent != undefined) {
			_curr = _curr.parent;
			if (_curr.isFolder) {
				_curr.folderAmount += 1;
			}
		}
		// add element to the big elements array
		array_push(elements, _element);
		return _element;
	}
	
	/// @desc Remove all elements from this inspector.
	/// @method RemoveElements()
	static RemoveElements = function() {
		var _size = array_length(elements), _item = undefined;
		for (var i = 0; i < _size; i++) {
			_item = elements[i];
			if (_item.Destroy != undefined) _item.Destroy();
		}
		array_resize(elements, 0);
		uiYoffset = 0;
		__bake();
	}
	
	/// @method SetTabsFolding(isOpened, from, to)
	/// @param {Bool} isOpened Defines if the range will be opened or closed.
	/// @param {Struct} from From item.
	/// @param {Struct} to To item.
	static SetTabsFolding = function(_isOpened, _from, _to=_from) {
		var _size = array_length(elements), _item = undefined;
		var _canChange = false;
		for (var i = 0; i < _size; i++) {
			_item = elements[i];
			if (_item == _from) _canChange = true;
			if (_canChange && _item.isFolder) {
				_item.isOpened = _isOpened;
			}
			if (_item == _to) _canChange = false;
		}
		uiYoffset = 0;
		__bake();
	}
	
	/// @desc Destroy inspector and its surface.
	static Destroy = function() {
		if (surface_exists(surface)) surface_free(surface);
		array_resize(elements, 0);
	}
	
	#endregion
}
#endregion

#region ELEMENTS
/// @desc Base element container class for all elements.
/// @ignore
function __Crystal_UIElement() : __Crystal_UIContainer() constructor {
	parent = undefined;
	type = "";
	xx = 0;
	yy = 0;
	width = 32;
	height = 32;
	alpha = 1;
	isFolder = false;
	isDynamic = false;
	alwaysVisible = false;
}
/// @desc Section element. Used for menus/collapsable stuff.
/// @ignore
function __Crystal_UIElementSection(_title, _isOpened, _style=1) : __Crystal_UIElement() constructor {
	type = "section";
	isFolder = true;
	folderAmount = 0; // not equivalent to children amount!
	children = [];
	text = _title;
	isOpened = _isOpened;
	height = 32;
	style = _style;
	
	static Draw = function(_ui) {
		// select
		if (canInteract && point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
			if (_ui.__inputLeftPressed) {
				_ui.FocusElement(self);
				isOpened = !isOpened;
			}
		}
		draw_set_color(c_white);
		
		// draw
		if (style == 0) {
			// big middle stype
			height = 24;
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_alpha(alpha);
			var _textWidth = string_width(text);
			var _textHeight = string_height(text);
			var _color = isOpened ? c_orange : c_lime;
			draw_set_color(_color);
			draw_sprite_stretched_ext(__cle_sprPixel, 0, xx+10, yy+_textHeight/2, (width/2-_textWidth/2)-20, 1, _color, alpha);
			draw_sprite_stretched_ext(__cle_sprPixel, 0, (xx+width/2+_textWidth/2)+10, yy+_textHeight/2, (width/2-_textWidth/2)-20, 1, _color, alpha);
			draw_text(xx+width/2, yy, text);
			draw_text(xx+16, yy+1, isOpened ? "v" : ">");
			draw_text(xx+width-16, yy+1, isOpened ? "v" : "<");
			draw_set_alpha(1);
			draw_set_halign(fa_left);
			draw_set_color(c_white);
		} else
		if (style == 1) {
			// big menu
			height = 32;
			draw_sprite_stretched_ext(__cle_sprPixel, 0, xx, yy, width, height, c_black, alpha*0.7);
			draw_set_valign(fa_middle);
			draw_set_color(isOpened ? c_orange : c_lime);
			draw_set_alpha(alpha);
			draw_text(xx+10, yy+(height/2)+1, text);
			draw_set_valign(fa_top);
			draw_set_alpha(1);
		} else
		if (style == 2) {
			// small menu
			height = 28;
			draw_sprite_stretched_ext(__cle_sprPixel, 0, xx, yy, width-8, height, c_black, alpha*0.5);
			draw_set_valign(fa_middle);
			draw_set_color(isOpened ? c_gray : c_silver);
			draw_set_alpha(alpha);
			draw_text(xx+10, yy+(height/2), (isOpened ? "v  " : ">  ") + text);
			draw_set_valign(fa_top);
			draw_set_alpha(1);
		}
	}
}
/// @desc Text. Use a callback to return custom text, or the ref variable.
/// @ignore
function __Crystal_UIElementText(_text="", _ref=undefined, _refName="", _callback=undefined) : __Crystal_UIElement() constructor {
	type = "text";
	text = _text;
	height = 32;
	callback = _callback;
	ref = _ref;
	refName = _refName;
	
	static Draw = function(_ui) {
		var _txt = text;
		// set from reference
		if (refName != "" && ref[$ refName] != undefined) {
			_txt = text + string(ref[$ refName]);
		}
		// set from callback
		if (callback != undefined) {
			_txt = text + callback(self);
		}
		var _width = width - 8;
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		draw_text_ext(xx, yy, _txt, -1, _width);
		height = string_height_ext(_txt, -1, _width);
		draw_set_alpha(1);
	}
}
/// @desc Checkbox element. If fireFunc is defined, the function will be responsible for doing the toggling. Useful if the function does other things.
/// @ignore
function __Crystal_UIElementCheckbox(_ref, _refName, _text=_refName, _callbackName=undefined, _callbackArgs=[], _callbackArgPos=0) : __Crystal_UIElement() constructor {
	type = "checkbox";
	text = _text;
	sprite = __cle_sprDebugUICheckbox;
	spriteWidth = sprite_get_width(sprite);
	spriteHeight = sprite_get_height(sprite);
	width = 16;
	height = spriteHeight;
	ref = _ref;
	refName = _refName;
	callbackName = _callbackName;
	callbackArgs = _callbackArgs;
	callbackArgPos = _callbackArgPos;
	
	static Draw = function(_ui) {
		var _refExists = (refName != "" && ref[$ refName] != undefined);
		if (_refExists) {
			// set focus
			if (canInteract && point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
				// press
				if (_ui.__inputLeftPressed) {
					_ui.FocusElement(self);
					if (callbackName == undefined) {
						ref[$ refName] = !ref[$ refName];
					} else {
						// instead of changing the variable directly, call a function
						callbackArgs[callbackArgPos] = !ref[$ refName]; // toggle parameter at the position
						method_call(method(ref, ref[$ callbackName]), callbackArgs);
					}
				}
			}
		}
		// draw
		var _color = _refExists ? c_white : c_dkgray;
		draw_set_color(_color);
		draw_set_alpha(alpha);
		draw_sprite_ext(sprite, ref[$ refName] ?? 0, xx, yy, 1, 1, 0, _color, alpha); // only set index if checked is not undefined
		draw_text(xx+spriteWidth+8, yy, text);
		draw_set_alpha(1);
	}
}
/// @desc Slider element.
/// @ignore
function __Crystal_UIElementSlider(_ref, _refName, _text=_refName, _min=0, _max=1, _steps=0, _callbackName=undefined, _callbackArgs=[], _callbackArgPos=0, _imediateMode=true) : __Crystal_UIElement() constructor {
	type = "slider";
	text = _text;
	height = 28;
	minVal = _min;
	maxVal = _max;
	steps = _steps;
	valueInit = _ref[$ _refName];
	value = valueInit;
	valueNormalized = 0;
	autoUpdate = false;
	ref = _ref;
	refName = _refName;
	callbackName = _callbackName;
	callbackArgs = _callbackArgs;
	callbackArgPos = _callbackArgPos;
	
	static __updateVariable = function(_value) {
		if (callbackName == undefined) {
			ref[$ refName] = _value;
		} else {
			// instead of changing the variable directly, call a function
			callbackArgs[callbackArgPos] = _value; // set parameter at the position
			method_call(method(ref, ref[$ callbackName]), callbackArgs);
		}
	}
	
	static Draw = function(_ui) {
		var _width = width - 64;
		var _variableReference = 0;
		
		var _refExists = (refName != "" && ref[$ refName] != undefined);
		if (_refExists) {
			_variableReference = ref[$ refName];
			// set focus
			if (canInteract && point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy+24-height/2, xx+_width, yy+24+height/3)) {
				if (_ui.__inputLeftPressed) {
					_ui.FocusElement(self);
				}
				if (_ui.__inputRightPressed) {
					__updateVariable(valueInit);
				}
				if (_ui.__inputMiddlePressed) {
					autoUpdate = !autoUpdate;
				}
			}
			
			// interpolate
			if (!autoUpdate) {
				valueNormalized = clamp(__cle_ui_linearstep(xx, xx+_width, _ui.__inputCursorX), 0, 1);
			} else {
				valueNormalized = sin(current_time*0.001) * 0.5 + 0.5;
			}
			isDynamic = autoUpdate;
			value = lerp(minVal, maxVal, valueNormalized);
			if (steps > 0) value = round(value * steps) / steps;
		
			// if focused
			if (_ui.__elementInFocus == self || autoUpdate) {
				__updateVariable(value);
			}
		}
		
		// draw
		var _valueNormalized = clamp(__cle_ui_linearstep(minVal, maxVal, _variableReference), 0, 1);
		var _color = (refName == "") ? c_dkgray : c_white;
		draw_set_color(_color);
		draw_set_alpha(alpha);
		draw_sprite_stretched_ext(__cle_sprPixel, 0, xx, yy+24, _width, 1, _color, alpha);
		draw_sprite_ext(__cle_sprDebugUIControl, 0, xx+_width*_valueNormalized, yy+24, 1, 1, 0, _color, alpha);
		draw_text(xx, yy, text);
		draw_text(xx+string_width(text)+10, yy, "("+string(minVal)+"/"+string(maxVal) + ") | " + string(_variableReference));
		draw_set_alpha(1);
	}
}
/// @desc Button element.
/// @ignore
function __Crystal_UIElementButton(_text, _callback=undefined, _argumentsArray=[], _ref=undefined, _refName="") : __Crystal_UIElement() constructor {
	type = "button";
	text = _text;
	callback = _callback;
	argumentsArray = _argumentsArray;
	ref = _ref;
	refName = _refName;
	sprite = __cle_sprDebugUIButton;
	spriteWidth = sprite_get_width(sprite);
	spriteHeight = sprite_get_height(sprite);
	width = 64;
	height = 24;
	
	static Draw = function(_ui) {
		width = string_width(text)+12;
		
		var _textColor = c_white;
		var _bgColor = make_color_rgb(50, 50, 50);
		
		// set focus
		if (canInteract && point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
			// press
			if (_ui.__inputLeftPressed) {
				_ui.FocusElement(self);
			}
			// hold
			if (_ui.__inputLeft) {
				_bgColor = make_color_rgb(30, 30, 30);;
			}
			//release
			if (_ui.__inputLeftReleased) {
				if (callback != undefined) method_call(callback, argumentsArray);
				_bgColor = c_silver;
			}
		}
		
		// draw
		draw_set_color(_textColor);
		// if variable exists, use it
		if (refName != "") {
			var _ref = ref[$ refName];
			if (_ref != undefined) {
				text = _ref;
			} else {
				_textColor = c_dkgray;
			}
		}
		draw_set_alpha(alpha);
		draw_sprite_stretched_ext(sprite, 0, xx, yy, width, height, _bgColor, alpha*0.6);
		draw_set_valign(fa_middle);
		draw_text(xx+6, yy+height/2, text);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(c_white);
	}
}
/// @desc Radio buttons element. The returned variable is an integer based on the radio item position in the array.
/// If you define the valuesArray, this will be used to set the variable.
/// @ignore
function __Crystal_UIElementRadio(_ref, _refName, _itemsArray=[], _valuesArray=[]) : __Crystal_UIElement() constructor {
	type = "radio";
	width = 150;
	height = 40;
	ref = _ref;
	refName = _refName;
	itemsArray = _itemsArray;
	valuesArray = _valuesArray;
	sprite = __cle_sprDebugUIRadio;
	spriteWidth = sprite_get_width(sprite);
	spriteHeight = sprite_get_height(sprite);
	
	static Draw = function(_ui) {
		var _refExists = (refName != "" && ref[$ refName] != undefined);
		var _color = _refExists ? c_white : c_dkgray;
		draw_set_color(_color);
		draw_set_alpha(alpha);
		// items
		var _paddingH = string_height("M");
		var i = 0, isize = array_length(itemsArray), _yy = yy;
		repeat(isize) {
			var _dest = i;
			if (array_length(valuesArray) > 0) _dest = valuesArray[i];
			
			if (_refExists && canInteract && point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, _yy, xx+width, _yy+_paddingH)) {
				if (_ui.__inputLeftPressed) {
					_ui.FocusElement(self);
					ref[$ refName] = _dest;
				}
			}
			draw_sprite_ext(sprite, _refExists ? (ref[$ refName] == _dest) : 0, xx, _yy, 1, 1, 0, _color, alpha); // only set index if checked is not undefined
			draw_text(xx+spriteWidth+8, _yy, itemsArray[i]);
			_yy += _paddingH + 4;
			++i;
		}
		height = (_yy - yy);
		draw_set_alpha(1);
	}
}
/// @desc Custom element. Execute a function with it. Parameters: (ui, element).
/// @ignore
function __Crystal_UIElementCustom(_onCreate=undefined, _onDraw=undefined) : __Crystal_UIElement() constructor {
	type = "custom";
	height = 32;
	drawFunction = _onDraw;
	
	if (_onCreate != undefined) _onCreate(self);
	
	static Draw = function(_ui) {
		if (drawFunction != undefined) drawFunction(self, _ui);
	}
}
/// @desc Separator bar element.
/// @ignore
function __Crystal_UIElementSeparator(_color=c_dkgray, _height=8) : __Crystal_UIElement() constructor {
	type = "separator";
	height = _height;
	color = _color;
	
	static Draw = function(_ui) {
		draw_set_color(color);
		draw_set_alpha(alpha);
		var _yy = yy+height/2;
		draw_line(xx, _yy, width, _yy);
		draw_set_alpha(1);
	};
}
/// @desc Empty space element.
/// @ignore
function __Crystal_UIElementEmptySpace(_height=32) : __Crystal_UIElement() constructor {
	type = "emptySpace";
	height = _height;
	
	static Draw = undefined;
}
/// @desc Sprite element. Subimg is optional.
/// @ignore
function __Crystal_UIElementSprite(_ref=undefined, _refNameSprite="", _refNameSpriteSubimg="", _maxHeight=128) : __Crystal_UIElement() constructor {
	type = "sprite";
	height = 32;
	maxHeight = _maxHeight;
	ref = _ref;
	refNameSprite = _refNameSprite;
	refNameSpriteSubimg = _refNameSpriteSubimg;
	
	static Draw = function(_ui) {
		if (refNameSprite != "" && ref[$ refNameSprite] != undefined) {
			draw_set_color(c_white);
			draw_set_alpha(alpha);
			// sprite
			var _sprite = ref[$ refNameSprite];
			if (sprite_exists(_sprite)) {
				var _spriteHeight = sprite_get_height(_sprite);
				var _scale = 1;
				if (maxHeight > 0) {
					_scale = maxHeight / _spriteHeight;
					if (_scale > 1) {
						height = max(maxHeight, _spriteHeight);
					} else {
						height = min(maxHeight, _spriteHeight);
					}
				} else {
					height = _spriteHeight;
				}
				var _subImg = ref[$ refNameSpriteSubimg];
				draw_sprite_ext(_sprite, _subImg ?? 0, xx+sprite_get_xoffset(_sprite)*_scale, yy+sprite_get_yoffset(_sprite)*_scale, _scale, _scale, 0, c_white, alpha);
			} else {
				height = 32;
			}
			draw_set_alpha(1);
		}
	}
}
/// @desc Surface element.
/// @ignore
function __Crystal_UIElementSurface(_ref=undefined, _refName="", _smoothPreview=true) : __Crystal_UIElement() constructor {
	type = "surface";
	height = 32;
	smoothPreview = _smoothPreview;
	ref = _ref;
	refName = _refName;
	
	static Draw = function(_ui) {
		if (refName != "" && ref[$ refName] != undefined) {
			draw_set_color(c_white);
			draw_set_alpha(alpha);
			// surface
			var _surface = ref[$ refName];
			if (surface_exists(_surface)) {
				var _oldTexFilter = gpu_get_tex_filter();
				gpu_set_tex_filter(smoothPreview);
				var _surfaceWidth = surface_get_width(_surface);
				var _surfaceHeight = surface_get_height(_surface);
				var _xScale = (width-8) / _surfaceWidth;
				var _yScale = _xScale;
				draw_surface_ext(_surface, xx, yy, _xScale, _yScale, 0, c_white, 1);
				height = _surfaceHeight * _yScale;
				gpu_set_tex_filter(_oldTexFilter);
			} else {
				height = 32;
			}
			draw_set_alpha(1);
		}
	}
}
/// @desc Color element (HSV). Use "exportHEX" as true if you want to export HEX color instead of RGB.
/// @ignore
function __Crystal_UIElementColor(_ref=undefined, _refName="", _wheelWidth=160, _exportHEX=true, _callbackName=undefined, _callbackArgs=[], _callbackArgPos=0) : __Crystal_UIElement() constructor {
	type = "color";
	ref = _ref;
	refName = _refName;
	callbackName = _callbackName;
	callbackArgs = _callbackArgs;
	callbackArgPos = _callbackArgPos;
	wheelWidth = _wheelWidth;
	height = _wheelWidth;
	pickerType = 0;
	selectedItem = undefined;
	hexColor = "";
	exportHex = _exportHEX;
	color = c_white;
	if (refName != "" && ref[$ refName] != undefined) {
		color = ref[$ refName];
	}
	hue = color_get_hue(color);
	sat = color_get_saturation(color);
	val = color_get_value(color);
	maxColors = 10;
	colorsHistory = array_create(maxColors, c_black);
	u_posRes = shader_get_uniform(__cle_shDebugGraph, "u_posRes");
	u_graphIndex = shader_get_uniform(__cle_shDebugGraph, "u_graphIndex");
	u_params = shader_get_uniform(__cle_shDebugGraph, "u_params");
	
	static hexToColor = function(_hexString) {
		// original implementation by xot / gmlscripts.com
		var _dig = "0123456789abcdef";
		_hexString = string_lower(_hexString);
		var _dec = 0;
		var _len = string_length(_hexString);
		for (var _pos = 1; _pos <= _len; _pos++) {
			_dec = _dec << 4 | (string_pos(string_char_at(_hexString, _pos), _dig) - 1);
		}
		var _col = (_dec & 16711680) >> 16 | (_dec & 65280) | (_dec & 255) << 16;
		return _col;
	}
	
	static colorToHex = function(_color, _len=1) {
		var _dig = "0123456789abcdef";
		var _dec;
		_dec = (_color & 0x000000FF) << 16 | (_color & 0x0000FF00) | (_color & 0x00FF0000) >> 16;
		var _hex = "";
		if (_dec < 0) {
			_len = max(_len, ceil(logn(16, 2 * abs(_dec))));
		}
		while(_len-- || _dec) {
			_hex = string_char_at(_dig, (_dec & 0xF) + 1) + _hex;
			_dec = _dec >> 4;
		}
		return "#" + _hex;
	}
	
	static __updateVariable = function(_value) {
		if (callbackName == undefined) {
			ref[$ refName] = _value;
		} else {
			// instead of changing the variable directly, call a function
			callbackArgs[callbackArgPos] = _value; // set parameter at the position
			method_call(method(ref, ref[$ callbackName]), callbackArgs);
		}
	}
	
	static Draw = function(_ui) {
		var _mx = _ui.__inputCursorX
		var _my = _ui.__inputCursorY;
		
		// draw
		draw_set_color(c_white);
		draw_set_alpha(alpha);
		
		var _refExists = (refName != "" && ref[$ refName] != undefined);
		if (_refExists) {
			color = ref[$ refName];
			hexColor = colorToHex(color);
		}
		
		var _curHue = color_get_hue(color),
			_curSat = color_get_saturation(color),
			_curVal = color_get_value(color),
			_curRed = color_get_red(color),
			_curGreen = color_get_green(color),
			_curBlue = color_get_blue(color),
			_canUpdateRefColor = false,
			_canAddToHistory = false;
		
		// set focus
		var _inFocus = false;
		if (point_in_rectangle(_mx, _my, xx, yy, xx+width, yy+height)) {
			// press
			if (_ui.__inputLeftPressed) {
				_ui.FocusElement(self);
			}
			// copy color to clipboard
			if (_ui.__inputRightPressed) {
				if (exportHex) {
					clipboard_set_text(hexColor);
				} else {
					clipboard_set_text($"{_curRed}, {_curGreen}, {_curBlue}");
				}
			}
			// paste color from clipboard
			if (_ui.__inputMiddlePressed) {
				var _clipboardCol = clipboard_get_text();
				if (_clipboardCol != "") {
					var _rgb;
					if (exportHex) {
						_rgb = hexToColor(_clipboardCol);
					} else {
						var _parsedRGB = string_split(_clipboardCol, ",", true);
						_rgb = make_color_rgb(real(_parsedRGB[0]), real(_parsedRGB[1]), real(_parsedRGB[2]));
					}
					hue = color_get_hue(_rgb);
					sat = color_get_saturation(_rgb);
					val = color_get_value(_rgb);
					_canUpdateRefColor = true;
					_canAddToHistory = true;
				}
			}
		}
		_inFocus = (_ui.__elementInFocus == self);
		
		// Graph
		var _graphH = wheelWidth,
			_graphW = _graphH,
			_graphX = xx,
			_graphY = yy,
			_graphCX = _graphX+_graphW/2,
			_graphCY = _graphY+_graphH/2,
			_graphCDist = point_distance(_graphCX, _graphCY, _mx, _my),
			_graphCDir = point_direction(_graphCX, _graphCY, _mx, _my),
			_graphRadius = _graphW/2,
			_graph1X = _graphX + 20,
			_graph1Y = _graphY + 20,
			_graph1W = _graphW - 40,
			_graph1H = _graphH - 40,
			_graph1Radius = _graph1W/2;
		
		if (pickerType == 0) {
			if (_inFocus && _ui.__inputLeftPressed) {
				if (_graphCDist <= _graph1Radius) {
					if (selectedItem == undefined) {
						selectedItem = 0;
					}
				}
				if (_graphCDist > _graph1Radius && _graphCDist < _graphRadius) {
					if (selectedItem == undefined) {
						selectedItem = 1;
					}
				}
			}
			
			if (selectedItem == 0) {
				hue = round((_graphCDir / 360) * 255);
				val = round((_graphCDist / _graph1Radius) * 255);
				_canUpdateRefColor = true;
			}
			if (selectedItem == 1) {
				sat = round((_graphCDir / 360) * 255);
				_canUpdateRefColor = true;
			}
			if (selectedItem == 0 || selectedItem == 1) {
				// save last color
				if (_ui.__inputLeftReleased) {
					_canAddToHistory = true;
				}
			}
			
			shader_set(__cle_shDebugGraph);
			shader_set_uniform_f(u_params, _curHue/255, _curSat/255, _curVal/255);
			shader_set_uniform_i(u_graphIndex, 0);
			shader_set_uniform_f(u_posRes, _graphX, _graphY, _graphW, _graphH);
			draw_rectangle(_graphX, _graphY, _graphX+_graphW, _graphY+_graphH, false);
			shader_set_uniform_i(u_graphIndex, 1);
			shader_set_uniform_f(u_posRes, _graph1X, _graph1Y, _graph1W, _graph1H);
			draw_rectangle(_graph1X, _graph1Y, _graph1X+_graph1W, _graph1Y+_graph1H, false);
			shader_reset();
			
			// thin wheel
			var _graphThinWheelAngle = (_curSat / 255) * 360;
			var _graphThinWheelDist = _graphRadius - 4;
			draw_sprite(__cle_sprDebugUIControl, 0, _graphCX+lengthdir_x(_graphThinWheelDist, _graphThinWheelAngle), _graphCY+lengthdir_y(_graphThinWheelDist, _graphThinWheelAngle));
			// shaped wheel
			var _graphShapedWheelAngle = (_curHue / 255) * 360;
			var _graphShapedWheelDist = (_curVal / 255) * _graph1Radius;
			draw_sprite(__cle_sprDebugUIControl, 0, _graphCX+lengthdir_x(_graphShapedWheelDist, _graphShapedWheelAngle), _graphCY+lengthdir_y(_graphShapedWheelDist, _graphShapedWheelAngle));
			
			// Current color
			//draw_sprite_ext(__cle_sprDebugUIControl, 0, xx+8, yy+8, 1, 1, 0, color, alpha);
			draw_circle_color(xx+8, yy+8, 10, color, color, false);
		}
		
		// Color History
		var _histX = xx + _graphW + 20,
			_histY = yy,
			_histItemX = _histX,
			_histItemY = _histY,
			_segmentWidth = 30,
			_segmentHeight = 16,
			i = 0, isize = array_length(colorsHistory), _colorHistory = undefined;
		if (isize > maxColors) {
			array_pop(colorsHistory);
			isize -= 1;
		}
		repeat(isize) {
			_colorHistory = colorsHistory[i];
			draw_set_color(_colorHistory);
			draw_rectangle(_histItemX, _histItemY, _histItemX+_segmentWidth-2, _histItemY+_segmentHeight, false);
			// select color from history
			if (_ui.__inputLeftPressed) {
				if (point_in_rectangle(_mx, _my, _histItemX, _histItemY, _histItemX+_segmentWidth-2, _histItemY+_segmentHeight)) {
					hue = color_get_hue(_colorHistory);
					sat = color_get_saturation(_colorHistory);
					val = color_get_value(_colorHistory);
					_canUpdateRefColor = true;
				}
			}
			_histItemX += _segmentWidth;
			if (_histItemX > width-_segmentWidth/2) {
				_histItemX = _histX;
				_histItemY += _segmentHeight+4;
			}
			++i;
		}
		draw_set_color(c_white);
		
		// Info
		var _infoX = xx + _graphW + 20;
		var _infoY = _histItemY + 24;
		draw_set_halign(fa_left);
		draw_set_color(c_gray);
		draw_text(_infoX, _infoY, $"HSV: {_curHue}, {_curSat}, {_curVal}\nRGB: {_curRed}, {_curGreen}, {_curBlue}\nHEX: {hexColor}");
		draw_set_color(c_white);
		
		// reset item
		if (_ui.__inputLeftReleased) {
			selectedItem = undefined;
		}
		if (_refExists) {
			// update variable
			if (_canUpdateRefColor) {
				__updateVariable(make_color_hsv(hue, sat, val));
			}
			// add to history
			if (_canAddToHistory) {
				if (colorsHistory[0] != ref[$ refName]) {
					array_insert(colorsHistory, 0, ref[$ refName]);
				}
			}
		}
		
		height = _graphW + 8;
		draw_set_alpha(1);
	}
}
/// @desc Srollbar (vertical) element.
/// @ignore
function __Crystal_UIElementScrollVertical(_ref=undefined, _refName="", _contentSizeRefName="", _scrollAmount=50, _scrollSpeed=0.3, _allowScrolling=true, _minBarHeight=24) : __Crystal_UIElement() constructor {
	type = "scrollVertical";
	width = 8;
	height = 64;
	ref = _ref;
	refName = _refName;
	contentSizeRefName = _contentSizeRefName;
	allowScrolling = _allowScrolling;
	scrollSpeed = _scrollSpeed;
	scrollAmount = _scrollAmount;
	isActive = false;
	isScrolling = false;
	valueNormalized = 0;
	oldValueNormalized = valueNormalized;
	barYRaw = 0; // this is an yy+ offset from 0 to +
	barY = 0; // this is equal to barYRaw, but smooth
	barMinHeight = _minBarHeight;
	
	static Draw = function(_ui) {
		var _refExists = (refName != "" && ref[$ refName] != undefined);
		if (_refExists) {
			var _contentSize = ref[$ contentSizeRefName];
			var _outsideArea = abs(_contentSize-height);
			var _barH = max(barMinHeight, height - _outsideArea);
			
			// only do something if scroll area is greater than height
			if (_contentSize > height) {
				isActive = true;
				
				if (canInteract && _ui.__inputLeftPressed) {
					if (point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy+barY, xx+width, yy+barY+_barH)) {
						_ui.FocusElement(self);
					} else
					if (point_in_rectangle(_ui.__inputCursorX, _ui.__inputCursorY, xx, yy, xx+width, yy+height)) {
						barYRaw = (_ui.__inputCursorY-yy) - _barH/2;
					}
				}
				if (_ui.__elementInFocus == self) barYRaw += _ui.__inputCursorDY;
				
				var _totalHeight = yy + height - yy - _barH;
				if (canInteract && allowScrolling) {
					barYRaw += (mouse_wheel_down() - mouse_wheel_up()) * (height / _contentSize) * 50;
				}
				barYRaw = clamp(barYRaw, 0, _totalHeight);
				barY = lerp(barY, barYRaw, scrollSpeed);
				valueNormalized = barY / _totalHeight;
				
				// check if is scrolling
				isScrolling = false;
				if (oldValueNormalized != valueNormalized) {
					oldValueNormalized = valueNormalized;
					isScrolling = true;
				}
				
				// return the offset
				ref[$ refName] = -lerp(0, _contentSize-height, valueNormalized);;
				
				// draw
				draw_set_color(c_silver);
				draw_set_alpha(alpha*0.6);
				draw_rectangle(xx, yy+barY, xx+width, yy+barY+_barH, false);
				draw_set_alpha(1);
				draw_set_color(c_white);
			} else {
				ref[$ refName] = 0;
				isActive = false;
				barYRaw = 0;
				barY = 0;
			}
		}
	}
}

#endregion
