
type = CRYSTAL_LIGHT.SHAPE;

vertexFormat = __crystalGlobal.vformatShapeLight;
vertexBuffer = vertex_create_buffer();
verticesAmount = 0;
matrix = matrix_build_identity();

dragging = false;
oldPath = path;
oldRadius = radius;
oldColor = color;
oldColorOuter = colorOuter;
oldCornerPrecision = cornerPrecision;
usingCustomPath = false;

generate = function() {
	if (path == undefined) exit;
	
	// Generate mesh from path
	pathLength = path_get_length(path);
	pathSize = path_get_number(path);
	pathClosed = path_get_closed(path);
	if (pathSize == 0) exit;
	
	// -----------------------------------------------
	// Create vertex buffer
	vertex_begin(vertexBuffer, vertexFormat);
	
	// Generate filled vertices
	// get centroid
	centroidX = 0;
	centroidY = 0;
	var i = 0;
	repeat(pathSize) {
		var p0 = i % pathSize;
	    centroidX += path_get_point_x(path, p0);
	    centroidY += path_get_point_y(path, p0);
		i++;
	}
	centroidX /= pathSize;
	centroidY /= pathSize;
	
	// find centroid's closest point and set new centroid position
	var closestX = 0;
	var closestY = 0;
	var minDist = infinity;
	i = 0;
	repeat(pathSize) {
		var p0 = i % pathSize;
		var _xx = path_get_point_x(path, p0);
		var _yy = path_get_point_y(path, p0);
		var dx = centroidX - _xx;
		var dy = centroidY - _yy;
		var dist = sqrt(dx * dx + dy * dy);
		if (dist < minDist) {
			minDist = dist;
			closestX = _xx;
			closestY = _yy;
		}
		i++;
	}
	centroidX = closestX;
	centroidY = closestY;
	
	// create inner vertices
	i = 0;
	repeat(pathSize+1) {// +1 to close the shape
		var p0 = i % pathSize;
		var xx = path_get_point_x(path, p0);
		var yy = path_get_point_y(path, p0);
		vertex_position(vertexBuffer, centroidX, centroidY); vertex_color(vertexBuffer, color, 1);
		vertex_position(vertexBuffer, xx, yy); vertex_color(vertexBuffer, color, 1);
		i++;
	}
	
	// generate outer vertices (only if radius is not 0)
	if (radius > 0) {
		// build first vertices to prevent glitch (only without culling!)
		//vertex_position(vertexBuffer, path_get_point_x(path, 0), path_get_point_y(path, 0)); vertex_color(vertexBuffer, color, 0);
		// init local variables
		var p0, p1, p2, p0x, p0y, p1x, p1y, p2x, p2y, v1X, v1Y, v2X, v2Y, _angle1, _angle2, _angle,
			_startAngle, _endAngle, _maxSegments, _segments, _angleDiff, _angleStep, _tetha, _extendedX, _extendedY;
		
		// build outer vertices
		for (i = 0; i <= pathSize; ++i) {
			//_reciprocal = i / (pathSize-1);
			// get indexes
			p0 = (i - 1 + pathSize) % pathSize; // previous (first)
			p1 = i % pathSize; // current (middle)
			p2 = (i + 1) % pathSize; // next (after)
			
			// get positions
			// previous (first)
			p0x = path_get_point_x(path, p0);
			p0y = path_get_point_y(path, p0);
			// current (middle)
			p1x = path_get_point_x(path, p1);
			p1y = path_get_point_y(path, p1);
			// next (after)
			p2x = path_get_point_x(path, p2);
			p2y = path_get_point_y(path, p2);
			
			// BUILD MESH
			// calculate vectors
			v1X = p1x - p0x;
			v1Y = p1y - p0y;
			v2X = p2x - p1x;
			v2Y = p2y - p1y;
			
			// calculate tangents
			_angle1 = point_direction(0, 0, v1X, v1Y);
			_angle2 = point_direction(0, 0, v2X, v2Y);
			_angle = __crystal_wrap(_angle1 - _angle2, 0, 360);
			
			// Draw the arc
			// calculate the start and end angles of the arc
			_startAngle = __crystal_wrap(_angle1+90, 0, 360);
			_endAngle = __crystal_wrap(_angle2+90, 0, 360);
			_angleDiff = angle_difference(_endAngle, _startAngle); // <0 = concave | >0 = convex
			
			// get segments amount based on angle
			_maxSegments = cornerPrecision;
			_segments = ceil(_maxSegments * (_angle / 180));
			_angleStep = (_angleDiff / _segments);
			
			// _angleDiff < 0 is to prevent creating additional vertices with negative angles (concave shape)
			if (i < pathSize && _angleDiff < 0) {
				// add arc
				for (var t = 0; t <= _segments; t++) {
					// add edge point
					vertex_position(vertexBuffer, p1x, p1y); vertex_color(vertexBuffer, color, 1);
					// add extended vertice
					_tetha = (_startAngle + (t * _angleStep));// % 360;
					if (_angleDiff > 0) {
						_tetha = mean(_startAngle, _endAngle);
					}
					_extendedX = p1x + lengthdir_x(radius, _tetha);
					_extendedY = p1y + lengthdir_y(radius, _tetha);
					vertex_position(vertexBuffer, _extendedX, _extendedY); vertex_color(vertexBuffer, colorOuter, 0); // alpha channel = attenuation falloff
				}
			} else {
				// do NOT add arc at the end
				// add edge point
				vertex_position(vertexBuffer, p1x, p1y); vertex_color(vertexBuffer, color, 1);
				// add extended vertice
				_tetha = _startAngle;
				if (_angleDiff > 0) {
					_tetha = mean(_startAngle, _endAngle);
				}
				_extendedX = p1x + lengthdir_x(radius, _tetha);
				_extendedY = p1y + lengthdir_y(radius, _tetha);
				vertex_position(vertexBuffer, _extendedX, _extendedY); vertex_color(vertexBuffer, colorOuter, 0); // alpha channel = attenuation falloff
			}
		}
	}
	vertex_end(vertexBuffer);
	
	verticesAmount = vertex_get_number(vertexBuffer);
}

// generate once
generate();
