renderer = new Crystal_Renderer();
renderer.SetRenderEnable(true);
renderer.SetDrawEnable(true); // disable it if using post processing
renderer.SetHDREnable(true);
renderer.SetMaterialsEnable(true);
renderer.SetLightsHDREnable(true);
renderer.SetLightsBlendmode(1);

// Enable depth buffer and alpha test
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(1);
application_surface_draw_enable(false); // disable automatic drawing of application_surface


// Create the normal map generator effect
normalsEffect = new Crystal_LayerFXNormalFromLuminance();
bgMatNormals = new Crystal_MaterialLayer(layer_get_depth("Tiles_2")-1, CRYSTAL_PASS.NORMALS, normalsEffect, true);
bgMatNormals.AddLayers(layer_get_id("Tiles_2"), layer_get_id("Tiles_2")); // range 1
bgMatNormals.Apply();

renderer.SetAmbientIntensity(0.15);
