#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform float u_time;
uniform float u_radius;
uniform float u_width;
uniform float u_border;
uniform vec2 u_center;
uniform vec2 u_resolution;

void main() {
    float r = u_radius + u_time * 0.6;
    float w = u_width;
    // 边缘半径随着半径变大而变宽
    float b = u_border * r * 30.5;
    vec2 off = u_center - v_texCoord;
    off.x *= u_resolution.x / u_resolution.y;
    float dis = length(off);
    float circle = smoothstep(r + w + b, r + w, dis) - smoothstep(r, r - b, dis);
    // 强度小一点
    circle *= 0.3;
    // 圆运动的最大边界
    circle *= max(0.3 - dis, 0.0);

    vec2 uv = v_texCoord + (v_texCoord - u_center) * circle;
    gl_FragColor = texture2D(u_texture, uv);
}
