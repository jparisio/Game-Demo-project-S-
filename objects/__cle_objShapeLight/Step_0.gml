
// update matrix
matrix = matrix_build(x, y, depth, 0, 0, angle, xScale, yScale, 1);

// detect variables change to regenerate mesh
if (path != oldPath || radius != oldRadius || color != oldColor || colorOuter != oldColorOuter || cornerPrecision != oldCornerPrecision) {
	generate();
	oldPath = path;
	oldRadius = radius;
	oldColor = color;
	oldColorOuter = colorOuter;
	oldCornerPrecision = cornerPrecision;
}
