#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform float u_brightness;

vec4 dim(vec4 c, float f) {
    return vec4(c.r * f, c.g * f, c.b * f, c.a);
}

void main() {
    vec4 col = v_fragmentColor * texture2D(u_texture, v_texCoord);
    col = dim(col, u_brightness);
    gl_FragColor = col;
}