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
    float r = u_radius / u_resolution.x + u_time / u_resolution.x;
    float w = u_width / u_resolution.x;
    float b = u_border / u_resolution.x * r * 30.5;
    vec2 off = v_texCoord - u_center;
//    off.x *= off.x * u_resolution.x / u_resolution.y;
    float dis = length(off);
    float circle = smoothstep(r + w + b, r + w, dis) - smoothstep(r, r - b, dis);

    circle *= 0.4;
    circle *= max(0.3 - dis, 0.0);
    vec2 uv = v_texCoord + (v_texCoord - u_center) * circle;
    vec4 tex = texture2D(u_texture, uv);

    gl_FragColor = vec4(tex.xyz, tex.w);
}
