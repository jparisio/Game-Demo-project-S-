
attribute vec4 in_Colour; // positionXY, depth, farZ
void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Colour.xy, 0.0, 1.0);
}
