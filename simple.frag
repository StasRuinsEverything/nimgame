precision mediump float;
varying vec4 v_color;
varying vec2 v_texcoord;
uniform sampler2D u_texture;

void main() {
    vec4 t4 = texture2D(u_texture, v_texcoord);
    gl_FragColor = t4 * v_color;
}