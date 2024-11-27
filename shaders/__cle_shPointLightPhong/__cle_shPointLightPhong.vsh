
attribute vec3 in_Position; // (x,y,z)
attribute vec4 in_Colour; // (r,g,b,a)
attribute vec2 in_TextureCoord; // (u,v) unused

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
varying vec3 v_vPosition;

void main() {
	gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * vec4(in_Position.xyz, 1.0);
	// get UV from NDC and normalize it
	v_vTexcoord = (gl_Position.xy / gl_Position.w)*0.5+0.5;
	#ifdef _YY_HLSL11_
	v_vTexcoord.y = 1.0-v_vTexcoord.y;
	#endif
	v_vPosition = in_Position.xyz;
	v_vColour = in_Colour;
}
