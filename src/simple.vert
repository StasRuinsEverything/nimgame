
attribute vec4 a_position;
attribute vec4 a_color;
attribute vec2 a_texcoord;

varying vec4 v_color;
varying vec2 v_texcoord;

void main() {
    gl_Position = a_position;
    v_color = a_color;
    v_texcoord = a_texcoord;
}