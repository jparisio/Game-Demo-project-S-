
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec3 v_vPosition;
varying vec4 v_vColour;

uniform float u_params; // intensity

void main() {
	gl_FragColor = vec4(v_vColour.rgb * u_params, 1.0);
}
