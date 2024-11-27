
varying vec2 v_vPosition;
varying vec4 v_vColour;

uniform vec4 u_posRes;
uniform int u_graphIndex;
uniform vec3 u_params;

#define M_TAU 6.2831853076

#region Color Spaces
const float YRGB_EPSILON = 1e-4;

vec3 HUEtoRGB(in float hue) {
	// Hue [0..1] to RGB [0..1]
	// See http://www.chilliant.com/rgb2hsv.html
	vec3 rgb = abs(hue * 6. - vec3(3, 2, 4)) * vec3(1, -1, -1) + vec3(-1, 2, 2);
	return clamp(rgb, 0., 1.);
}

vec3 RGBtoHCV(in vec3 rgb) {
	// RGB [0..1] to Hue-Chroma-Value [0..1]
	// Based on work by Sam Hocevar and Emil Persson
	vec4 p = (rgb.g < rgb.b) ? vec4(rgb.bg, -1., 2. / 3.) : vec4(rgb.gb, 0., -1. / 3.);
	vec4 q = (rgb.r < p.x) ? vec4(p.xyw, rgb.r) : vec4(rgb.r, p.yzx);
	float c = q.x - min(q.w, q.y);
	float h = abs((q.w - q.y) / (6. * c + YRGB_EPSILON) + q.z);
	return vec3(h, c, q.x);
}

vec3 HSVtoRGB(in vec3 hsv) {
	// Hue-Saturation-Value [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsv.x);
    rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing
	return ((rgb - 1.) * hsv.y + 1.) * hsv.z;
}

vec3 HSLtoRGB(in vec3 hsl) {
	// Hue-Saturation-Lightness [0..1] to RGB [0..1]
	vec3 rgb = HUEtoRGB(hsl.x);
	float c = (1. - abs(2. * hsl.z - 1.)) * hsl.y;
	return (rgb - 0.5) * c + hsl.z;
}

vec3 RGBtoHSV(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Value [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float s = hcv.y / (hcv.z + YRGB_EPSILON);
	return vec3(hcv.x, s, hcv.z);
}

vec3 RGBtoHSL(in vec3 rgb) {
	// RGB [0..1] to Hue-Saturation-Lightness [0..1]
	vec3 hcv = RGBtoHCV(rgb);
	float z = hcv.z - hcv.y * 0.5;
	float s = hcv.y / (1. - abs(z * 2. - 1.) + YRGB_EPSILON);
	return vec3(hcv.x, s, z);
}
#endregion

void main() {
	vec2 uv = (v_vPosition-u_posRes.xy) / u_posRes.zw;
	
	vec3 col;
	float alpha = 1.0;
	
	if (u_graphIndex == 0) {
		// wheel (saturation)
		float dist = length(uv-0.5)*2.0;
		col = HSVtoRGB(vec3(u_params.x, fract(atan(1.0-uv.y-0.5, uv.x-0.5)/M_TAU), 1.0));
		alpha = smoothstep(dist, dist+0.02, 1.0) * smoothstep(0.9, 0.92, dist);
	} else
	if (u_graphIndex == 1) {
		// wheel (hue + value)
		float dist = length(uv-0.5)*2.0;
		col = HSVtoRGB(vec3(fract(atan(1.0-uv.y-0.5, uv.x-0.5)/M_TAU), 1.0, dist));
		alpha = smoothstep(dist, dist+0.02, 1.0);
	}
	
	gl_FragColor = vec4(col, v_vColour.a * alpha);
}
