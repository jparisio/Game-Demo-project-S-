
// Feather ignore all

#macro CLE_VERSION "v1.0"
#macro CLE_RELEASE_DATE "November, 14, 2024"

show_debug_message($"Crystal Lighting Engine {CLE_VERSION} | Copyright (C) 2024 FoxyOfJungle");

// ============================================================================================

/// @ignore
function __crystalGlobal() {
	// Default textures
	static textureMaterial = sprite_get_texture(__cle_sprDefMaterial, 0);
	static textureNormal = sprite_get_texture(__cle_sprDefNormal, 0);
	static textureBlack = sprite_get_texture(__cle_sprDefBlack, 0);
	static textureWhite = sprite_get_texture(__cle_sprDefWhite, 0);
	
	// Vertex Formats
	static vformatVertexShadows = undefined;
	static vformatVertexSpriteShadows = undefined;
	static vformatShapeLight = undefined;
	// vertex shadows
	vertex_format_begin();
	vertex_format_add_custom(vertex_type_float4, vertex_usage_color);
	vertex_format_add_custom(vertex_type_float4, vertex_usage_color);
	vformatVertexShadows = vertex_format_end();
	// vertex sprite shadows
	vertex_format_begin();
	vertex_format_add_custom(vertex_type_float3, vertex_usage_color);
	vertex_format_add_custom(vertex_type_float4, vertex_usage_color);
	vertex_format_add_custom(vertex_type_float3, vertex_usage_color);
	vformatVertexSpriteShadows = vertex_format_end();
	// shape lights
	vertex_format_begin();
	vertex_format_add_position();
	vertex_format_add_color();
	vformatShapeLight = vertex_format_end();
	
	// Declare global variables
	global.__CrystalCurrentRenderer = undefined;
}

// Crystal init
__crystalGlobal();
