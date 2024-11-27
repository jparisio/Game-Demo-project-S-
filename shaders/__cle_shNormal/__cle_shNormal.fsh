
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying mat2 v_vRotationMatrix;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main() {
	vec4 normal = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	normal.xyz = (normal.xyz * 2.0 - 1.0); // to tangent space
	normal.xy *= v_vRotationMatrix;
	normal.xyz = (normal.xyz * 0.5 + 0.5); // to texture space again
	gl_FragColor = normal;
}
