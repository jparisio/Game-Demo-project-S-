
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texelSize;
uniform float u_blurAmount;

#define ITERATIONS 32.0
#define goldenAngle 2.39996323

void main() {
	vec2 radius = u_texelSize * u_blurAmount;
	vec4 blur;
	float total;
	for(float i = 0.0; i < ITERATIONS; i+=goldenAngle) {
		blur += texture2D(gm_BaseTexture, v_vTexcoord + vec2(cos(i), sin(i)) * sqrt(i) * radius);
		total++;
	}
	blur /= total;
    gl_FragColor = blur;
}
