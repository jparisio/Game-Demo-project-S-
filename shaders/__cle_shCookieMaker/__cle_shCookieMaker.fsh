
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_intensity;
uniform float u_power;
uniform float u_distortionAmount;
uniform float u_distortionSmoothness;
uniform float u_distortionFrequency;
uniform float u_outerSmoothness;
uniform float u_innerSmoothness;
uniform float u_innerScale;
uniform float u_outerScale;
uniform float u_polarProjectionEnable;
uniform float u_polarProjectionRadial;

#define M_PI 3.14159265358979323844

float linearstep(float _a, float _b, float _value) {
	return (_value - _a) / (_b - _a);
}

void main() {
	// Copyright (C) 2024, Mozart Junior (@foxyofjungle)
	vec2 uv = v_vTexcoord;
	vec2 uvCentered = uv * 2.0 - 1.0;
	float radius = length(uv);
	float radiusCentered = length(uvCentered);
	float ripple = smoothstep(u_distortionSmoothness, 0.0, sin(radiusCentered * u_distortionFrequency)*0.5+0.5) * u_distortionAmount;
	if (u_polarProjectionEnable > 0.5) {
		float polarCentered = atan(uvCentered.y, uvCentered.x);
		float xProj = polarCentered * (0.5/M_PI)+0.5;
		float yProj = linearstep(u_innerScale, u_outerScale, radiusCentered);
		uv.x = xProj + ripple;
		uv.y = yProj;
		if (u_polarProjectionRadial > 0.5) {
			uv.y = xProj;
			uv.x = yProj + ripple;
		}
	} else {
		uv -= 0.5;
		float polar = atan(uv.y, uv.x) + ripple;
		uv = vec2(cos(polar), sin(polar)) * length(uv);
		uv += 0.5;
	}
	vec4 color = texture2D(gm_BaseTexture, uv);
	color.rgb = mix(color.rgb, vec3(0.0),
		smoothstep(1.0-u_outerSmoothness, 1.0, radiusCentered) +
		smoothstep(1.0-u_innerSmoothness, 1.0, 1.0-radiusCentered)
	);
	color.rgb = pow(color.rgb, vec3(u_power));
	color.rgb *= u_intensity;
	gl_FragColor = color;
}
