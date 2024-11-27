
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_emission;

void main() {
	vec4 mainTex = texture2D(gm_BaseTexture, v_vTexcoord) * v_vColour;
	if (mainTex.a < 0.01) discard;
	gl_FragColor = vec4(mainTex.rgb*u_emission, mainTex.a);
}
