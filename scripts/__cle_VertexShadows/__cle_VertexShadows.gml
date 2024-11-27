
/// Feather ignore all
/// @desc A shadow caster is an area where light will be blocked and shadows will be projected. This shadow is vertex-based. You can move and rotate the shadow by accessing its variables.
/// 
/// Static shadows are MUCH more efficient, useful for scenarios. Use dynamic shadows for things that move, but be careful with performance.
/// 
/// The id is used exclusively to get the initial depth, rotation and scale from the instance (if exists). If you want to update it later, it must be done manually.
///
/// Avoid decimal depth, as you may get into trouble (like z fighting).
/// @param {Id.Instance,Struct} startId The instance to get default properties. Use noone if you want to use default properties (position, angle and depth: 0, scale: 1).
/// @param {Enum.CRYSTAL_SHADOW} shadowType Shadow type enum. Example: CRYSTAL_SHADOW.STATIC.
/// @param {Macro} transformMode Shadow transformation mode. Default: SHADOW_SOFT_TRANSFORMED. Changing this influences performance: soft shadows require more CPU to build vertices.
/// @returns {Struct} 
function Crystal_Shadow(_startId, _shadowType, _transformMode=SHADOW_SOFT_TRANSFORMED) constructor {
	static defaultOwner = {depth : 0, x : 0, y : 0, image_angle : 0, image_xscale : 1, image_yscale : 1};
	if (!instance_exists(_startId)) {
		_startId = defaultOwner;
	}
	// base
	__cull = false;
	__frames = []; // array of arrays (meshes with edges) - this is for animation
	__renderer = undefined;
	__destroyed = false;
	__applied = false;
	__type = _shadowType;
	__mode = _transformMode;
	
	// variables
	enabled = true;
	self.x = _startId.x;
	self.y = _startId.y;
	self.depth = _startId.depth;
	xScale = _startId.image_xscale;
	yScale = _startId.image_yscale;
	angle = _startId.image_angle;
	frame = 0;
	frameCount = 0;
	shadowLength = 50;
	
	#region Public Methods
	
	/// @desc Remove this shadow caster from the lighting system. Use this when destroying objects that cast shadows.
	/// @method Destroy()
	static Destroy = function() {
		__destroyed = true;
		__applied = false;
		if (__type == CRYSTAL_SHADOW.STATIC && __renderer != undefined) {
			__renderer.__vbuffStaticRebuild = true;
		}
	}
	
	/// @desc Apply shadow caster, adding it to a Crystal_Renderer(). If not specified, adds to the last created renderer (or set with crystal_set_renderer()).
	/// @param {Struct.Crystal_Renderer} renderer The renderer to add the group for rendering. If not specified, adds to the last created renderer (or set with crystal_set_renderer()).
	static Apply = function(_renderer=global.__CrystalCurrentRenderer) {
		// check
		if (__applied) return;
		if (_renderer == undefined) {
			__crystal_trace("Shadow not created, renderer not found. (creation order?)", 1);
			return;
		}
		if (array_length(__frames) <= 0) {
			__crystal_trace("Shadow not created. No meshes added previously", 1);
			return;
		}
		// add to renderer (once)
		__renderer = _renderer;
		_renderer.__addShadowCaster(self);
		__applied = true;
		__destroyed = false;
	}
	
	/// @desc Associate a mesh with a frame. Useful for animated vertex shadows. Use -1 to increment the frame with each function call.
	/// @method AddMesh(frame, mesh)
	/// @param {Struct.Crystal_ShadowMesh} mesh The mesh to associate to the frame.
	/// @param {Real} frame The frame to associate the mesh.
	static AddMesh = function(_mesh, _frame=-1) {
		if (_frame < 0) {
			__frames[frameCount] = _mesh;
			frameCount++;
		} else {
			__frames[_frame] = _mesh;
		}
		return self;
	}
	
	/// @desc Add previously created meshes from an array. Each array position is a frame, counting from 0.
	/// @method AddMeshes(meshesArray)
	/// @param {Array<Struct.Crystal_ShadowMesh>} meshesArray The array of meshes to copy from.
	static AddMeshes = function(_meshesArray) {
		var i = 0, isize = array_length(_meshesArray);
		repeat(isize) {
			__frames[i] = _meshesArray[i];
			i++;
		}
		frameCount = i;
		return self;
	}
	
	/// @desc Remove all meshes references from this shadow caster.
	/// @method RemoveMeshes()
	static RemoveMeshes = function() {
		array_resize(__frames, 0);
		frameCount = 0;
		return self;
	}
	
	#endregion
}

/// @desc Creates a local-space mesh to be used as a frame for a shadow caster. This should be added to a Crystal_Shadow().
/// NOTE: This struct only contains an array of points, which are garbage collected, so you don't need to destroy it. The vertex buffer generation occurs in the Crystal_Renderer() itself.
function Crystal_ShadowMesh() constructor {
	__vertexArray = [];
	
	#region Public Methods
	/// @desc Add edges to the mesh. Edges are lines with two points/positions. Edges should be added in clockwise direction.
	/// @method AddEdge(x1, y1, x2, y2)
	/// @param {Real} x1 X position of the first point.
	/// @param {Real} y1 Y position of the first point.
	/// @param {Real} x2 X position of the second point.
	/// @param {Real} y2 Y position of the second point.
	static AddEdge = function(_x1, _y1, _x2, _y2) {
		array_push(__vertexArray, _x1, _y1, _x2, _y2);
	}
	
	/// @desc Remove all edges of a Crystal_Shadow().
	/// @method ClearEdges()
	static ClearEdges = function() {
		array_resize(__vertexArray, 0);
	}
	
	/// @desc Creates a polygon based on path points. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromPath(pathAsset, relative)
	/// @param {Asset.GMPath} pathAsset The path asset index.
	/// @returns {Struct.Crystal_ShadowMesh}
	static FromPath = function(_pathAsset) {
		// add edges from path points
		var _points = path_get_number(_pathAsset),
			_closed = path_get_closed(_pathAsset),
			_firstPointX = path_get_point_x(_pathAsset, 0),
			_firstPointY = path_get_point_y(_pathAsset, 0),
			_xC = _firstPointX,
			_yC = _firstPointY,
			_xN = 0,
			_yN = 0,
			i = 0;
		repeat(_points) {
			_xN = path_get_point_x(_pathAsset, i);
			_yN = path_get_point_y(_pathAsset, i);
			AddEdge(_xC, _yC, _xN, _yN);
			_xC = _xN;
			_yC = _yN;
			++i;
		}
		if (_closed) {
			AddEdge(_xC, _yC, _firstPointX, _firstPointY);
		}
		return self;
	}
	
	/// @desc Creates a polygon based on path points. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromJson(jsonString, closed)
	/// @param {String} jsonString The JSON string to parse points from. The format must be like this: `"[[-7,-10],[1,-9],[15,-22]]"` (a JSON string with an array of [x, y] points).
	/// @param {Bool} closed If true, connect the last vertex with the first vertex.
	/// @returns {Struct.Crystal_ShadowMesh}
	static FromJson = function(_jsonString, _closed=true) {
		var _json = json_parse(_jsonString);
		var _pointsArray = _json;
		if (!is_array(_pointsArray)) {
			__crystal_trace("Crystal_ShadowMesh: Failed to add from Json. Invalid format", 1);
			exit;
		}
		// add edges from json points
		var _points = array_length(_pointsArray),
			_firstPointX = _pointsArray[0][0],
			_firstPointY = _pointsArray[0][1],
			_xC = _firstPointX, // x
			_yC = _firstPointY, // y
			_xN = 0,
			_yN = 0,
			_point,
			i = 0;
		repeat(_points) {
			_point = _pointsArray[i];
			_xN = _point[0]; // x
			_yN = _point[1]; // y
			AddEdge(_xC, _yC, _xN, _yN);
			_xC = _xN;
			_yC = _yN;
			++i;
		}
		if (_closed) {
			AddEdge(_xC, _yC, _firstPointX, _firstPointY);
		}
		return self;
	}
	
	/// @desc Creates a polygon based on an array of sequencial x and y. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromArray(array)
	/// @param {Array} array The array with points sequencially. Example: [x, y, x, y, x, y...]
	static FromArray = function(_array) {
		var _points = _array,
			_len = array_length(_points),
			_px = _points[_len-2],
			_py = _points[_len-1],
			_nx = 0,
			_ny = 0,
			i = 0;
		while(i < _len) {
			_nx = _points[i++];
			_ny = _points[i++];
			AddEdge(_px, _py, _nx, _ny);
			_px = _nx;
			_py = _ny;
		}		
		return self;
	}
	
	/// @desc Creates a polygon based on a rectangle shape. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromRect(width, height, isCentered)
	/// @param {Real} width The shape width.
	/// @param {Real} height The shape height.
	/// @param {Bool} isCentered If true, the rectangle will be centered.
	/// @returns {Struct.Crystal_ShadowMesh}
	static FromRect = function(_width, _height, _isCentered) {
		// add edges in rectangle
		var _xOffset = 0,
			_yOffset = 0;
		if (_isCentered) {
			_xOffset = _width/2;
			_yOffset = _height/2;
		}
		var _l = -_xOffset,
		_t = -_yOffset,
		_r = _width-_xOffset,
		_b = _height-_yOffset;
		AddEdge(_l, _t, _r, _t); // top
		AddEdge(_r, _t, _r, _b); // right
		AddEdge(_r, _b, _l, _b); // bottom
		AddEdge(_l, _b, _l, _t); // left
		return self;
	}
	
	/// @desc Creates a polygon based on a circle shape. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromCircle(radius, isCentered, edges)
	/// @param {Real} radius The shape radius.
	/// @param {Bool} isCentered If true, the ellipse will be centered.
	/// @param {Real} edges Ellipse precision. Min 3 edges.
	/// @returns {Struct.Crystal_ShadowMesh}
	static FromCircle = function(_radius, _isCentered, _edges=8) {
		_edges = max(_edges, 3);
		var _center = _radius,
		if (_isCentered) {
			_center = 0;
		}
		var _thetaStep = (2*pi) / _edges,
			_theta = 0,
			_xp = _center + (cos(_theta) * _radius),
			_yp = _center + (-sin(_theta) * _radius),
			_nx = 0,
			_ny = 0,
			i = 0;
		repeat(_edges+1) {
			_nx = _center + (cos(_theta) * _radius);
			_ny = _center + (-sin(_theta) * _radius);
			AddEdge(_xp, _yp, _nx, _ny);
			_xp = _nx;
			_yp = _ny;
			_theta += _thetaStep;
			++i;
		}
		return self;
	}
	
	/// @desc Creates a polygon based on an ellipse shape. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromEllipse(width, height, isCentered, edges)
	/// @param {Real} width The shape width.
	/// @param {Real} height The shape height.
	/// @param {Bool} isCentered If true, the ellipse will be centered.
	/// @param {Real} edges Ellipse precision. Min 3 edges.
	/// @returns {Struct.Crystal_ShadowMesh}
	static FromEllipse = function(_width, _height, _isCentered, _edges=8) {
		_edges = max(_edges, 3);
		var _centerX = _width/2,
			_centerY = _height/2;
		if (_isCentered) {
			_centerX = 0;
			_centerY = 0;
		}
		var	_radiusX = _width/2,
			_radiusY = _height/2,
			_thetaStep = (2*pi) / _edges,
			_theta = 0,
			_xp = _centerX + (cos(_theta) * _radiusX),
			_yp = _centerY + (-sin(_theta) * _radiusY),
			_nx = 0,
			_ny = 0,
			i = 0;
		repeat(_edges+1) {
			_nx = _centerX + (cos(_theta) * _radiusX);
			_ny = _centerY + (-sin(_theta) * _radiusY);
			AddEdge(_xp, _yp, _nx, _ny);
			_xp = _nx;
			_yp = _ny;
			_theta += _thetaStep;
			++i;
		}
		return self;
	}
	
	/// @desc Creates a rectangle polygon based on a sprite size. Tip: sprite_index. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromSpriteRect(sprite, padding)
	/// @param {Asset.GMSprite} sprite The sprite asset to generate a rectangle based on the sprite size and offset.
	/// @param {Real} padding Additional offset. Positive = inner.
	static FromSpriteRect = function(_sprite, _padding=0) {
		// add edges
		var _width = sprite_get_width(_sprite)-_padding*2,
		_height = sprite_get_height(_sprite)-_padding*2,
		_xOffset = sprite_get_xoffset(_sprite)-_padding,
		_yOffset = sprite_get_yoffset(_sprite)-_padding;
		FromRect(_width, _height, _xOffset, _yOffset);
		return self;
	}
	
	/// @desc Creates a ellipse polygon based on a sprite size. Tip: sprite_index. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromSpriteEllipse(sprite, padding, edges)
	/// @param {Asset.GMSprite} sprite The sprite asset to generate an ellipse based on the sprite size and offset.
	/// @param {Real} padding Additional offset. Positive = inner.
	/// @param {Real} edges Ellipse precision. Min 3 edges.
	static FromSpriteEllipse = function(_sprite, _padding=0, _edges=8) {
		_edges = max(_edges, 3);
		var _xOffset = sprite_get_xoffset(_sprite),
	        _yOffset = sprite_get_yoffset(_sprite),
			_width = sprite_get_width(_sprite),
			_height = sprite_get_height(_sprite),
			_centerX = (_width / 2) - _xOffset,
			_centerY = (_height / 2) - _yOffset,
			_radiusX = (_width / 2) - _padding,
			_radiusY = (_height / 2) - _padding,
			_thetaStep = (2*pi) / _edges,
			_theta = 0,
			_xp = _centerX + (cos(_theta) * _radiusX),
			_yp = _centerY + (-sin(_theta) * _radiusY),
			_nx = 0,
			_ny = 0,
			i = 0;
		repeat(_edges) {
			_theta += _thetaStep;
			_nx = _centerX + (cos(_theta) * _radiusX);
			_ny = _centerY + (-sin(_theta) * _radiusY);
			AddEdge(_xp, _yp, _nx, _ny);
			_xp = _nx;
			_yp = _ny;
			++i;
		}
		return self;
	}
	
	/// @desc Creates a polygon based on a sprite bounding box (bbox). The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromSpriteBBoxRect(sprite, padding)
	/// @param {Asset.GMSprite} sprite The sprite asset to generate a rectangle based on the bounding box.
	/// @param {Real} padding Additional offset. Positive = inner.
	static FromSpriteBBoxRect = function(_sprite, _padding=0) {
		var _xOffset = sprite_get_xoffset(_sprite),
	        _yOffset = sprite_get_yoffset(_sprite),
			_l = sprite_get_bbox_left(_sprite)+_padding - _xOffset,
			_t = sprite_get_bbox_top(_sprite)+_padding - _yOffset,
			_r = sprite_get_bbox_right(_sprite)-_padding - _xOffset,
			_b = sprite_get_bbox_bottom(_sprite)-_padding - _yOffset;
		AddEdge(_l, _t, _r, _t); // top
		AddEdge(_r, _t, _r, _b); // right
		AddEdge(_r, _b, _l, _b); // bottom
		AddEdge(_l, _b, _l, _t); // left
		return self;
	}
	
	/// @desc Creates a polygon based on a sprite bounding box (bbox), with ellipse shape. The rotation and scale are from the Crystal_Shadow() itself.
	/// @method FromSpriteBBoxEllipse(sprite, padding, edges)
	/// @param {Asset.GMSprite} sprite The sprite asset to generate an ellipse based on the bounding box.
	/// @param {Real} padding Additional offset. Positive = inner.
	/// @param {Real} edges Ellipse precision. Min 3 edges.
	static FromSpriteBBoxEllipse = function(_sprite, _padding=0, _edges=8) {
		_edges = max(_edges, 3);
		var _xOffset = sprite_get_xoffset(_sprite),
	        _yOffset = sprite_get_yoffset(_sprite),
			_l = sprite_get_bbox_left(_sprite)+_padding - _xOffset,
			_t = sprite_get_bbox_top(_sprite)+_padding - _yOffset,
			_r = sprite_get_bbox_right(_sprite)-_padding - _xOffset,
			_b = sprite_get_bbox_bottom(_sprite)-_padding - _yOffset,
			_centerX = (_l + _r) / 2,
			_centerY = (_t + _b) / 2,
			_radiusX = (_r - _l) / 2,
			_radiusY = (_b - _t) / 2,
			_thetaStep = (2*pi) / _edges,
			_theta = 0,
			_xp = _centerX + (cos(_theta) * _radiusX),
			_yp = _centerY + (-sin(_theta) * _radiusY),
			_nx = 0,
			_ny = 0,
			i = 0;
		repeat(_edges) {
			_theta += _thetaStep;
			_nx = _centerX + (cos(_theta) * _radiusX);
			_ny = _centerY + (-sin(_theta) * _radiusY);
			AddEdge(_xp, _yp, _nx, _ny);
			_xp = _nx;
			_yp = _ny;
			++i;
		}
		return self;
	}
	#endregion
}


// ===================================================
#region Shadow Vertex Builders

/// @ignore
function __cle_shadowBuildSoftTransformed(_vbuff) {
	gml_pragma("forceinline");
	var
	_sin = dsin(angle),
	_cos = dcos(angle),
	_xSin = xScale * _sin,
	_xCos = xScale * _cos,
	_ySin = yScale * _sin,
	_yCos = yScale * _cos,
	_depth = depth,
	_shadowLength = shadowLength,
	_vertexArray = __frames[frame].__vertexArray, _pointAx, _pointAy, _pointBx, _pointBy, _vertAx, _vertAy, _vertBx, _vertBy,
	i = 0, isize = array_length(_vertexArray);
	// for each line segment, add triangles (segments are sequencial)
	repeat(isize div 4) {
		// get local coordinates
		_pointAx = _vertexArray[i++];
		_pointAy = _vertexArray[i++];
		_pointBx = _vertexArray[i++];
		_pointBy = _vertexArray[i++];
		
		// position + local position transformed (local to world-space)
		_vertAx = x + _pointAx*_xCos + _pointAy*_ySin;
		_vertAy = y - _pointAx*_xSin + _pointAy*_yCos;
		_vertBx = x + _pointBx*_xCos + _pointBy*_ySin;
		_vertBy = y - _pointBx*_xSin + _pointBy*_yCos;
		
		// add triangles to the vertex buffer
		// X, Y, Z (DEPTH), ZFAR  |  texCoordXY, shadowLength, penumbraOffset
		// hard shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		// triangle 2
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		
		// soft shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 0, 0, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 0, 1, _shadowLength, 1); // penumbra offset
		// triangle 2
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 0, 1, _shadowLength, -1); // penumbra offset
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 0, 0, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
	}
}

/// @ignore
function __cle_shadowBuildHardTransformed(_vbuff) {
	gml_pragma("forceinline");
	var
	_sin = dsin(angle),
	_cos = dcos(angle),
	_xSin = xScale * _sin,
	_xCos = xScale * _cos,
	_ySin = yScale * _sin,
	_yCos = yScale * _cos,
	_depth = depth,
	_shadowLength = shadowLength,
	_vertexArray = __frames[frame].__vertexArray, _pointAx, _pointAy, _pointBx, _pointBy, _vertAx, _vertAy, _vertBx, _vertBy,
	i = 0, isize = array_length(_vertexArray);
	// for each line segment, add triangles (segments are sequencial)
	repeat(isize div 4) {
		// get local coordinates
		_pointAx = _vertexArray[i++];
		_pointAy = _vertexArray[i++];
		_pointBx = _vertexArray[i++];
		_pointBy = _vertexArray[i++];
		
		// position + local position transformed (local to world-space)
		_vertAx = x + _pointAx*_xCos + _pointAy*_ySin;
		_vertAy = y - _pointAx*_xSin + _pointAy*_yCos;
		_vertBx = x + _pointBx*_xCos + _pointBy*_ySin;
		_vertBy = y - _pointBx*_xSin + _pointBy*_yCos;
		
		// add triangles to the vertex buffer
		// hard shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		// triangle 2
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
	}
}

/// @ignore
function __cle_shadowBuildSoftNoTransform(_vbuff) {
	gml_pragma("forceinline");
	var
	_depth = depth,
	_shadowLength = shadowLength,
	_vertexArray = __frames[frame].__vertexArray, _vertAx, _vertAy, _vertBx, _vertBy,
	i = 0, isize = array_length(_vertexArray);
	// for each line segment, add triangles (segments are sequencial)
	repeat(isize div 4) {
		// position + local position transformed (local to world-space)
		_vertAx = x + _vertexArray[i++] * xScale;
		_vertAy = y + _vertexArray[i++] * yScale;
		_vertBx = x + _vertexArray[i++] * xScale;
		_vertBy = y + _vertexArray[i++] * yScale;
		
		// add triangles to the vertex buffer
		// hard shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		// triangle 2
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		
		// soft shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 0, 0, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 0, 1, _shadowLength, 1);
		// triangle 2
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 0, 1, _shadowLength, -1);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 0, 0, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
	}
}

/// @ignore
function __cle_shadowBuildHardNoTransform(_vbuff) {
	gml_pragma("forceinline");
	var
	_depth = depth,
	_shadowLength = shadowLength,
	_vertexArray = __frames[frame].__vertexArray, _vertAx, _vertAy, _vertBx, _vertBy,
	i = 0, isize = array_length(_vertexArray);
	// for each line segment, add triangles (segments are sequencial)
	repeat(isize div 4) {
		// position + local position transformed (local to world-space)
		_vertAx = x + _vertexArray[i++] * xScale;
		_vertAy = y + _vertexArray[i++] * yScale;
		_vertBx = x + _vertexArray[i++] * xScale;
		_vertBy = y + _vertexArray[i++] * yScale;
		
		// add triangles to the vertex buffer
		// hard shadows
		// triangle 1
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		// triangle 2
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 0); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertAx, _vertAy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
		vertex_float4(_vbuff, _vertBx, _vertBy, _depth, 1); vertex_float4(_vbuff, 1, 1, _shadowLength, 0);
	}
}

#endregion
