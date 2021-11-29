#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform vec3 u_color;
uniform float u_width;

void main() {
    float w = u_width;
    vec4 color = v_fragmentColor * texture2D(CC_Texture0, v_texCoord);
    if (color.a < THRESHOLD) {
        float alpha = 0.0;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(w, 0)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(-w, 0)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(0, w)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(0, -w)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(w, w)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(-w, w)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(w, -w)).a;
        alpha += texture2D(CC_Texture0, v_texCoord + vec2(-w, -w)).a;
        alpha = clamp(alpha, 0.0, 1.0);
        if (alpha < THRESHOLD) {
            discard;
        }
        gl_FragColor = vec4(u_color, alpha);
    }
    else {
        gl_FragColor = color;
    }
}
