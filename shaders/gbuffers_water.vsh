#version 120

varying vec3 Normal;

void main(){
    gl_Position = ftransform();
    Normal = gl_NormalMatrix * gl_Normal;
}