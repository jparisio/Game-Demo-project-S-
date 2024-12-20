renderer = new Crystal_Renderer();
renderer.SetRenderEnable(true);
renderer.SetDrawEnable(true); // disable it if using post processing
renderer.SetHDREnable(true);
renderer.SetMaterialsEnable(true);
renderer.SetLightsHDREnable(true);
renderer.SetLightsBlendmode(1);
//ambienece
renderer.SetAmbientIntensity(0.2);
// Enable depth buffer and alpha test
gpu_set_zwriteenable(true);
gpu_set_ztestenable(true);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(1);
application_surface_draw_enable(false); // disable automatic drawing of application_surface


//// Create the normal map generator effect
//normalsEffect = new Crystal_LayerFXNormalFromLuminance();
//normalsEffect.strengthX = 1;
//normalsEffect.strengthY = 1;
//bgMatNormals = new Crystal_MaterialLayer(layer_get_depth("Tiles_1")-1, CRYSTAL_PASS.NORMALS, normalsEffect , true);
//bgMatNormals.AddLayers(layer_get_id("Tiles_1"), layer_get_id("Tiles_1")); // range 1
//bgMatNormals.Apply();



