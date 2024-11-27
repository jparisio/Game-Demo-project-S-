
// Feather ignore all

#region Enums
	enum CRYSTAL_PASS {
		LIGHT,
		NORMALS,
		MATERIAL,
		EMISSIVE,
		REFLECTIONS,
		COMBINE,
	}
	
	enum CRYSTAL_MATERIAL {
		METALLIC,
		ROUGHNESS,
		AO,
		MASK, // NOT IMPLEMENTED YET...
	}
		
	enum CRYSTAL_LIGHT {
		BASIC,
		DIRECT,
		SHAPE,
		SPRITE,
		SPOT,
		POINT
	}
	
	enum CRYSTAL_SHADOW {
		STATIC,
		DYNAMIC,
	}
	
	enum CRYSTAL_SHADOW_MODE {
		SPRITE,
		SPRITE_BAKED,
	}
#endregion

#region Macros
	#macro LIT_LESS_EQUAL cmpfunc_lessequal
	#macro LIT_LESS cmpfunc_less
	#macro LIT_GREATER_EQUAL cmpfunc_greaterequal
	#macro LIT_GREATER cmpfunc_greater
	#macro LIT_EQUAL cmpfunc_equal
	#macro LIT_NOT_EQUAL cmpfunc_notequal
	#macro LIT_ALWAYS cmpfunc_always
	
	#macro LIGHT_SHADER_BASIC 0
	#macro LIGHT_SHADER_PHONG 1
	#macro LIGHT_SHADER_BRDF 2
	
	#macro SHADOW_SOFT_TRANSFORMED __cle_shadowBuildSoftTransformed
	#macro SHADOW_HARD_TRANSFORMED __cle_shadowBuildHardTransformed
	#macro SHADOW_SOFT_NO_TRANSFORM __cle_shadowBuildSoftNoTransform
	#macro SHADOW_HARD_NO_TRANSFORM __cle_shadowBuildHardNoTransform
#endregion
