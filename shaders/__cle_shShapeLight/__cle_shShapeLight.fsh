
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec4 v_vColour;

uniform vec4 u_params; // intensity, inner, falloff, levels

#define EPSILON 0.0001

void main() {
	float lightAttenuation = pow(smoothstep(0.0, 1.0-u_params.y, v_vColour.a), u_params.z*2.0+EPSILON);
	lightAttenuation = floor(lightAttenuation * u_params.w + 0.5) / u_params.w;
	gl_FragColor = vec4(v_vColour.rgb * lightAttenuation * u_params.x, 1.0);
}
