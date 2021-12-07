#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform vec3 u_color;
uniform float u_width;
uniform float u_threshold;
uniform vec2 u_resolution;

void main() {
    vec2 s = u_width * 1.0 / u_resolution.xy;
    vec4 color = v_fragmentColor * texture2D(u_texture, v_texCoord);
    if (color.a < u_threshold) {
        float alpha = 0.0;
        alpha += texture2D(u_texture, v_texCoord + vec2(s.x, 0)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-s.x, 0)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(0, s.y)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(0, -s.y)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(s.x, s.y)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-s.x, s.y)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(s.x, -s.y)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-s.x, -s.y)).a;
        alpha = clamp(alpha, 0.0, 1.0);
        if (alpha < u_threshold) {
            discard;
        }
        gl_FragColor = vec4(u_color, alpha);
    }
    else {
        gl_FragColor = color;
    }
}
