#version 120

/*
const int colortex1Format = RGBA32F;
*/

varying vec2 TexCoords;

uniform sampler2D depthtex0, depthtex1;
uniform sampler2D colortex0, colortex1;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferProjection;

#define RAY_MARCH_STEPS 256

// No binary refinement to keep things simple
vec3 ComputeSSR(void){
    vec3 ClipSpace = vec3(TexCoords, texture2D(depthtex0, TexCoords).x) * 2.0f - 1.0f;
    vec3 Normal = normalize(texture2D(colortex0, TexCoords).rgb * 2.0f - 1.0f);
    vec4 ClipSpaceToViewSpace = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
    vec3 ViewSpace = ClipSpaceToViewSpace.xyz / ClipSpaceToViewSpace.w;
    vec3 ViewDirection = normalize(ViewSpace);
    vec3 RayDirection = reflect(ViewDirection, Normal);
    vec3 ViewSpaceWithRayDirection = ViewSpace + RayDirection;
    vec4 ScreenSpaceRayDirectionW = gbufferProjection *  vec4(ViewSpaceWithRayDirection, 1.0f);
    vec3 ScreenSpaceRayDirection = normalize(ScreenSpaceRayDirectionW.xyz / ScreenSpaceRayDirectionW.w - ClipSpace) * 0.01f;
    vec3 RayMarchPosition = ClipSpace;
    for(int i = 0; i < RAY_MARCH_STEPS; i++){
        RayMarchPosition += ScreenSpaceRayDirection;
        vec3 ScreenSpace = RayMarchPosition * 0.5f + 0.5f;
        if(any(lessThan(ScreenSpace.xy, vec2(0.0f))) || any(greaterThan(ScreenSpace.xy, vec2(1.0f)))){
            return vec3(0.0f);
        } else if(texture2D(depthtex0, ScreenSpace.xy).x < ScreenSpace.z){
            return texture2D(colortex0,ScreenSpace.xy).rgb;
        }
        //ScreenSpaceRayDirection *= 1.5f;
    }
    return texture2D(colortex0, RayMarchPosition.xy * 0.5f + 0.5f).rgb;
}

void main() {
    vec3 Color;
    bool WaterMask = texture2D(colortex1, TexCoords).x > 1.1f;
    if(WaterMask){
        Color.rgb = ComputeSSR();
    } else {
        Color.rgb = texture2D(colortex0, TexCoords).rgb;
    }
    /* DRAWBUFFERS:0 */
    gl_FragData[0] = vec4(Color, 1.0f);
}