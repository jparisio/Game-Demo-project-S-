varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float shake_val;

void main() {
    // Define offsets for each channel
    vec2 off_red = vec2(0.021, shake_val);
    vec2 off_green = vec2(shake_val, 0.016);
    vec2 off_blue = vec2(-0.016, shake_val);
    
    // Fetch the texture with the respective offsets
    vec4 red = texture2D(gm_BaseTexture, v_vTexcoord + off_red);
    vec4 green = texture2D(gm_BaseTexture, v_vTexcoord + off_green);
    vec4 blue = texture2D(gm_BaseTexture, v_vTexcoord + off_blue);
    
    // Combine the channels (no custom colors for now)
    vec4 output_color = vec4(red.r, green.g, blue.b, 1.0);
    
    // Apply the final color to the fragment
    gl_FragColor = v_vColour * output_color;
}
