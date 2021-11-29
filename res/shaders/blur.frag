#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform float u_blur;
uniform float u_brightness;
uniform vec2 u_center;

vec4 dim(vec4 c, float f) {
    return vec4(c.r * f, c.g * f, c.b * f, c.a);
}

float rand(vec2 p) {
    return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

//vec3 hash3(vec2 p) {
//    vec3 q = vec3(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)), dot(p, vec2(419.2, 371.9)));
//    return fract(sin(q) * 43758.5453);
//}

#if BLUR_TYPE == 1
void blur(out vec4 tex) {
    float deg = 360. / SAMPLE_NUM;
    for (int i = 0; i < SAMPLE_NUM; i++) {
        float c = cos(degrees(deg * i));
        float s = sin(degrees(deg * i));
        vec2 q = vec2(c, s) * (rand(vec2(i, v_texCoord.x + v_texCoord.y)) + u_blur);
        vec2 uv = v_texCoord + (q * u_blur);
        tex += texture2D(CC_Texture0, uv).rgba / 2.;

        q = vec2(c, s) * (rand(vec2(i, v_texCoord.x + v_texCoord.y + 24.)) + u_blur);
        uv = v_texCoord + (q * u_blur);
        tex += texture2D(CC_Texture0, uv).rgba / 2.;
    }
    tex /= SAMPLE_NUM;
}
#endif

#if BLUR_TYPE == 2
void blur(out vec4 tex) {
    float w = u_blur * 0.625f;
    tex = texture2D(CC_Texture0, v_texCoord) * 8;
    tex += texture2D(CC_Texture0, v_texCoord + vec2(w, 0)) * 3;
    tex += texture2D(CC_Texture0, v_texCoord + vec2(-w, 0)) * 3;
    tex += texture2D(CC_Texture0, v_texCoord + vec2(0, w)) * 3;
    tex += texture2D(CC_Texture0, v_texCoord + vec2(0, -w)) * 3;
    tex += texture2D(CC_Texture0, v_texCoord + vec2(w, w));
    tex += texture2D(CC_Texture0, v_texCoord + vec2(-w, w));
    tex += texture2D(CC_Texture0, v_texCoord + vec2(w, -w));
    tex += texture2D(CC_Texture0, v_texCoord + vec2(-w, -w));
    tex /= 24;
}
#endif

#if BLUR_TYPE == 3
void blur(out vec4 tex) {
    vec2 d = v_texCoord - u_center;
    for (int j = 0; j < SAMPLE_NUM; j++) {
        tex += texture2D(CC_Texture0, v_texCoord - d * u_blur * j);
    }
    tex /= SAMPLE_NUM;
}
#endif

void main() {
    vec4 tex = vec4(0.);

    #ifdef BLUR_TYPE
        blur(tex);
    #elif
        tex = texture2D(CC_Texture0, v_texCoord);
    #endif

    tex *= v_fragmentColor;
    tex = dim(tex, u_brightness);
    gl_FragColor = tex;
}
