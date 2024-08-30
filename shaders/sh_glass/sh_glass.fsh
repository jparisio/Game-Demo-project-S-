varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D distortion_texture_page; // the name of the surface in the shader	

void main()
{
    // Find the offset colour for this location (this is where the magic happens) 
    vec2 distort_amount = (v_vColour * texture2D(distortion_texture_page, v_vTexcoord)).xy;

    // Flip the x-axis distortion (for normal maps)
    distort_amount.x = 1.0 - distort_amount.x;

    // Normalize and wrap-around distort amount
    distort_amount -= 0.5;
    if (distort_amount.x > 0.5) { distort_amount.x -= 1.0; }
    if (distort_amount.y > 0.5) { distort_amount.y -= 1.0; }
    distort_amount /= 4.0;

    // Apply the distortion to the main texture
    gl_FragColor = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord + distort_amount);
}
