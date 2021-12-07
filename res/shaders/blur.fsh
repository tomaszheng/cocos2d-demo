#ifdef GL_ES
precision lowp float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

uniform sampler2D u_texture;

uniform int u_blurType;
uniform int u_sampleNum;
uniform float u_radius;
uniform vec2 u_resolution;
uniform float u_brightness;
uniform vec2 u_center;

vec4 dim(vec4 c, float f) {
    return vec4(c.r * f, c.g * f, c.b * f, c.a);
}

float rand(vec2 p) {
    return fract(sin(dot(p.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rand2(vec2 p) {
    vec2 q = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(q) * 43758.5453);
}

//vec3 hash3(vec2 p) {
//    vec3 q = vec3(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)), dot(p, vec2(419.2, 371.9)));
//    return fract(sin(q) * 43758.5453);
//}

void normal(out vec4 col) {
    vec2 r = u_radius * 1.0 / u_resolution.xy;
    col = texture2D(u_texture, v_texCoord) * 8;
    col += texture2D(u_texture, v_texCoord + vec2(r.x, 0)) * 3;
    col += texture2D(u_texture, v_texCoord + vec2(-r.x, 0)) * 3;
    col += texture2D(u_texture, v_texCoord + vec2(0, r.y)) * 3;
    col += texture2D(u_texture, v_texCoord + vec2(0, -r.y)) * 3;
    col += texture2D(u_texture, v_texCoord + vec2(r.x, r.y));
    col += texture2D(u_texture, v_texCoord + vec2(-r.x, r.y));
    col += texture2D(u_texture, v_texCoord + vec2(r.x, -r.y));
    col += texture2D(u_texture, v_texCoord + vec2(-r.x, -r.y));
    col /= 24;
}

void frosted(out vec4 col) {
    vec2 r = u_radius * 1.0 / u_resolution.xy;
    float deg = 360. / u_sampleNum;
    for (int i = 0; i < u_sampleNum; i++) {
        float c = cos(degrees(deg * i));
        float s = sin(degrees(deg * i));
        vec2 q = vec2(c, s) * (rand2(vec2(i, v_texCoord.x + v_texCoord.y)) + r);
        vec2 uv = v_texCoord + (q * r);
        col += texture2D(u_texture, uv).rgba / 2.;

        q = vec2(c, s) * (rand2(vec2(i, v_texCoord.x + v_texCoord.y + 24.)) + r);
        uv = v_texCoord + (q * r);
        col += texture2D(u_texture, uv).rgba / 2.;
    }
    col /= u_sampleNum;
}

void radial(out vec4 col) {
    vec2 r = u_radius * 1.0 / u_resolution.xy;
    vec2 d = v_texCoord - u_center;
    for (int j = 0; j < u_sampleNum; j++) {
        col += texture2D(u_texture, v_texCoord - d * r * j);
    }
    col /= u_sampleNum;
}

void gaussian(out vec4 col) {
    float r = u_radius;
    float s = r / u_sampleNum;
    float n = 0;
    vec2 u = 1.0 / u_resolution.xy;
    for (float x = -r; x < r; x += s) {
        for (float y = -r; y < r; y +=s) {
            float w = (r - abs(x)) * (r - abs(y));
            col += texture2D(u_texture, v_texCoord + vec2(x * u.x, y * u.y)) * w;
            n += w;
        }
    }
    col /= n;
}

void main() {
    vec4 col = vec4(0.);

    if (u_blurType == 1) {
        normal(col);
    }
    else if (u_blurType == 2) {
        frosted(col);
    }
    else if (u_blurType == 3) {
        radial(col);
    }
    else if (u_blurType == 4) {
        gaussian(col);
    }
    else {
        col = texture2D(u_texture, v_texCoord);
    }
    col *= v_fragmentColor;
    col = dim(col, u_brightness);
    gl_FragColor = col;
}
