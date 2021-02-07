#version 120

varying vec3 Normal;

void main(){
    /* DRAWBUFFERS:01 */
    gl_FragData[0] = vec4(Normal * 0.5f + 0.5f, 1.0f);
    gl_FragData[1] = vec4(10.0f);
}