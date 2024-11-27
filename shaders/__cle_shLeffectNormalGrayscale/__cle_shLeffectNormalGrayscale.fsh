
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: FoxyOfJungle#0167
-------------------------------------------------------------------*/

varying mat2 v_vRotationMatrix;
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2 u_texel;
uniform vec2 u_offset;
uniform vec2 u_strength;
uniform vec2 u_threshold;
uniform float u_blurAmount;
uniform float u_outlineRadius;

const vec3 lumWeights = vec3(0.2126, 0.7152, 0.0722);
float GetLuminance(vec3 color) {
	return dot(color, lumWeights);
}

void main() {
	// get albedo
	vec4 albedo = texture2D(gm_BaseTexture, v_vTexcoord);
	
	// generate normal from luminance
	vec4 luma = vec4(
		GetLuminance(texture2D(gm_BaseTexture, v_vTexcoord + u_texel * vec2(u_offset.x, 0.0), u_blurAmount).rgb),
		GetLuminance(texture2D(gm_BaseTexture, v_vTexcoord + u_texel * vec2(-u_offset.x, 0.0), u_blurAmount).rgb),
		GetLuminance(texture2D(gm_BaseTexture, v_vTexcoord - u_texel * vec2(0.0, u_offset.y), u_blurAmount).rgb),
		GetLuminance(texture2D(gm_BaseTexture, v_vTexcoord - u_texel * vec2(0.0, -u_offset.y), u_blurAmount).rgb)
	);
	luma = smoothstep(u_threshold.x, u_threshold.y, luma);
	vec2 dxy = vec2(luma.y-luma.x, luma.w-luma.z) * u_strength;
	vec3 normal = vec3(normalize(vec3(dxy, 1.0))); // tangent space
	
	// rotate
	normal.xy *= v_vRotationMatrix;
	normal = (normal * 0.5 + 0.5); // to texture space again
	albedo.rgb = normal;
	
	// outline (if available)
	if (u_outlineRadius > 0.0) {
		vec2 xOffset = vec2(u_texel.x * u_outlineRadius, 0.0);
		vec2 yOffset = vec2(0.0, u_texel.y * u_outlineRadius);
		float outline = 1.0 - albedo.a;
		outline += (1.0 - texture2D(gm_BaseTexture, v_vTexcoord - xOffset).a);
		outline += (1.0 - texture2D(gm_BaseTexture, v_vTexcoord + xOffset).a);
		outline += (1.0 - texture2D(gm_BaseTexture, v_vTexcoord - yOffset).a);
		outline += (1.0 - texture2D(gm_BaseTexture, v_vTexcoord + yOffset).a);
		albedo = mix(albedo, vec4(vec3(0.5, 0.5, 1.0), 1.0), step(outline, 0.0));
	}
	gl_FragColor = albedo;
}
