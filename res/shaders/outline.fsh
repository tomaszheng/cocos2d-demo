#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform vec3 u_color;
uniform float u_width;
uniform float u_threshold;

void main() {
    float w = u_width;
    vec4 color = v_fragmentColor * texture2D(u_texture, v_texCoord);
    if (color.a < u_threshold) {
        float alpha = 0.0;
        alpha += texture2D(u_texture, v_texCoord + vec2(w, 0)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-w, 0)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(0, w)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(0, -w)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(w, w)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-w, w)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(w, -w)).a;
        alpha += texture2D(u_texture, v_texCoord + vec2(-w, -w)).a;
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
