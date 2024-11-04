
	varying vec2 v_vTexcoord;
	varying vec4 v_vColour;
	
	uniform float	time;
	uniform vec2	strength;
	uniform float	size;
	uniform float	bend;
	
	uniform sampler2D distort_tex;


void main() {
	// distortion offset (red):
	vec2 distort		= texture2D(distort_tex, fract(v_vTexcoord * size + vec2(0.0, time))).rr;
	distort.x			-= 0.5; // to keep the flame horizontally centered

	// distortion strength factor (green):
	vec2 distort_str;
	distort_str.x		= texture2D(distort_tex, vec2(v_vTexcoord.x * 0.5,			v_vTexcoord.y)).g * strength.x;
	distort_str.y		= texture2D(distort_tex, vec2(v_vTexcoord.x * 0.5 + 0.5,	v_vTexcoord.y)).g * strength.y;
	
	// apply distrotion strength:
	distort				*= distort_str;
	
	// bend flame (blue):
	distort.x			+= texture2D(distort_tex, v_vTexcoord).b * bend; // -1 <= bend <= +1
	
	// Output:	
	gl_FragColor		= v_vColour * texture2D( gm_BaseTexture, v_vTexcoord + distort);
}




