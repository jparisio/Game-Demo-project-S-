// Fragment shader to make the output color red
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    gl_FragColor.rgb = vec3(1.0, 0.0, 0.0); // Set the color to red
}
