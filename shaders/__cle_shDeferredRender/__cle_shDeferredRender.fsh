
/*------------------------------------------------------------------
You cannot redistribute this pixel shader source code anywhere.
Only compiled binary executables. Don't remove this notice, please.
Copyright (C) 2024 Mozart Junior (FoxyOfJungle). Kazan Games Ltd.
Website: https://foxyofjungle.itch.io/ | Discord: @foxyofjungle
-------------------------------------------------------------------*/

// prefs (for optimization, comment the definition)
#define ENABLE_DITHERING
#define ENABLE_AMBIENT_LUT
#define ENABLE_MATERIALS
//#define ADDITIVE_EMISSION
#define LIGHTS_COMPENSATION 3.0

varying vec2 v_vPosition;
varying vec2 v_vTexcoord;
uniform vec2 u_resolution;
uniform vec4 u_camRect;
uniform vec3 u_ambientColor;
uniform sampler2D u_ambientColorLutTex;
uniform vec2 u_ambientColorLUTsize;
uniform vec2 u_ambientColorLUTtiles;
uniform vec4 u_ambientColorLutUVs;
uniform float u_ambientIntensity;
uniform sampler2D u_materialTexture;
uniform sampler2D u_lightsTexture;
uniform float u_lightsIntensity;
uniform int u_lightsBlendMode;
uniform sampler2D u_emissiveTexture;
uniform float u_ditheringEnable;
uniform float u_ditheringBayerSize;
uniform sampler2D u_ditheringBayerTexture;
uniform vec4 u_ditheringBayerUVs;
uniform float u_ditheringBitLevels;
uniform float u_ditheringThreshold;

#region Common

float Saturate(float x) {
	return clamp(x, 0.0, 1.0);
}

vec2 Saturate(vec2 x) {
	return clamp(x, 0.0, 1.0);
}

vec3 Saturate(vec3 x) {
	return clamp(x, 0.0, 1.0);
}

vec4 Saturate(vec4 x) {
	return clamp(x, 0.0, 1.0);
}

vec3 Blend(vec3 source, vec3 dest) {
	return source + dest - source * dest;
}

vec3 Blend(vec3 source, vec4 dest) {
	return dest.rgb * dest.a + source * (1.0-dest.a);
}

vec4 Blend(vec4 source, vec4 dest) {
	return dest * dest.a + source * (1.0-dest.a);
}

const float YRGB_EPSILON = 1e-6;

vec3 RGBtoHCV(in vec3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
	vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + YRGB_EPSILON) + q.z);
	return vec3(h, c, q.x);
}

vec3 RGBtoHSV(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + YRGB_EPSILON);
	return vec3(hcv.x, s, hcv.z);
}

vec3 ApplyLUT(vec3 color) {
	// Copyright (C) 2024, Mozart Junior (@foxyofjungle)
	vec2 tiles = u_ambientColorLUTtiles;
	float z = Saturate(color.b) * (tiles.x * tiles.y - 1.0);
	float z1 = floor(z);
	float z2 = ceil(z);
	vec2 tile1;
		tile1.y = floor(z1 / tiles.x);
		tile1.x = floor(z1 - tile1.y * tiles.x);
	vec2 tile2;
		tile2.y = floor(z2 / tiles.x);
		tile2.x = floor(z2 - tile2.y * tiles.x);
	vec2 tileSize = u_ambientColorLUTsize / tiles;
	vec2 tileUV = mix(0.5/tileSize, (tileSize-0.5)/tileSize, Saturate(color.rg));
	return mix(
		texture2D(u_ambientColorLutTex, mix(u_ambientColorLutUVs.xy, u_ambientColorLutUVs.zw, (tile1/tiles)+(tileUV/tiles))).rgb,
		texture2D(u_ambientColorLutTex, mix(u_ambientColorLutUVs.xy, u_ambientColorLutUVs.zw, (tile2/tiles)+(tileUV/tiles))).rgb,
		z-z1 // frac
	);
}
#endregion

void main() {
	vec2 uv = v_vTexcoord;
	vec4 albedoTex = texture2D(gm_BaseTexture, uv);
	vec3 colFinal = albedoTex.rgb;
	
	#ifdef ENABLE_MATERIALS
		// Ambient occlusion
		colFinal *= texture2D(u_materialTexture, uv).b;
	#endif
	
	// Ambient color
	#ifdef ENABLE_AMBIENT_LUT
		colFinal = ApplyLUT(colFinal);
	#endif
	colFinal = mix(colFinal, u_ambientColor, u_ambientIntensity);
	
	// Lights
	// alpha is irrelevant, because lights are added
	vec3 lightsTex = max(texture2D(u_lightsTexture, uv).rgb, 0.0) * u_lightsIntensity;
	// < add different effects to all lights here >
	
	// Dithering
	#ifdef ENABLE_DITHERING
		if (u_ditheringEnable > 0.5) {
			vec2 uvDither = mod(u_camRect.xy + v_vPosition.xy / floor(u_resolution/u_camRect.zw), u_ditheringBayerSize)/u_ditheringBayerSize;
			uvDither = mix(u_ditheringBayerUVs.xy, u_ditheringBayerUVs.zw, uvDither); // atlas uv
			float matrix = texture2D(u_ditheringBayerTexture, uvDither).r;
			//lightsTex = floor(lightsTex * u_ditheringBitLevels + max(matrix-u_ditheringThreshold, 0.0)) / u_ditheringBitLevels;
			lightsTex *= step(max(matrix-u_ditheringThreshold, 0.0), RGBtoHSV(lightsTex).z);
		}
	#endif
	
	// Blend Lights
	if (u_lightsBlendMode == 0) {
		colFinal += (lightsTex*LIGHTS_COMPENSATION)*albedoTex.rgb; // multiply (natural)
		//colFinal = Blend(colFinal, albedoTex.rgb * lightsTex); // screen multiply (natural 2)
	} else
	if (u_lightsBlendMode == 1) {
		colFinal = mix(colFinal, (normalize(lightsTex + 0.05)*LIGHTS_COMPENSATION)*albedoTex.rgb, lightsTex); // normalized multiply
	} else
	if (u_lightsBlendMode == 2) {
		colFinal = mix(colFinal, (lightsTex*LIGHTS_COMPENSATION)*albedoTex.rgb, lightsTex); // linear multiply
	} else
	if (u_lightsBlendMode == 3) {
		colFinal += lightsTex; // add
	}
	
	#ifdef ENABLE_MATERIALS
		// Blend Emissive with HDR support
		vec3 emissiveTex = texture2D(u_emissiveTexture, uv).rgb;
		#ifdef ADDITIVE_EMISSION
		colFinal += emissiveTex;
		#else
		colFinal = mix(colFinal, emissiveTex, emissiveTex); // linear interpolation looks more natural and colorful
		#endif
	#endif
	
	// Final pixels
	colFinal = max(colFinal, 0.0); // prevent negative output
	//colFinal = vec3(texture2D(u_materialTexture, uv).a);
	gl_FragColor = vec4(colFinal, 1.0);
}
