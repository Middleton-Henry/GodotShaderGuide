shader_type canvas_item;

uniform int _shaderPass = 4;
uniform float _noiseScale = 12;

void vertex() {
}

float whiteNoise(vec2 input){
	return fract(sin(dot(input, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

float simplexNoise(vec2 v) {
    const vec4 C = vec4(
        0.211324865405187,  // (3.0 - sqrt(3.0)) / 6.0
        0.366025403784439,  // 0.5 * (sqrt(3.0) - 1.0)
       -0.577350269189626,  // -1.0 + 2.0 * C.x
        0.024390243902439   // 1.0 / 41.0
    );

    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);

    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec2 x1 = x0 - i1 + C.xx;
    vec2 x2 = x0 + C.zz;

    i = mod289(i);
    vec3 p = permute(
        permute(i.y + vec3(0.0, i1.y, 1.0))
      + i.x + vec3(0.0, i1.x, 1.0)
    );

    vec3 m = max(
        0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)),
        0.0
    );
    m = m * m;
    m = m * m;

    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;

    m *= 1.79284291400159 - 0.85373472095314 *
         (a0 * a0 + h * h);

    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.y = a0.y * x1.x + h.y * x1.y;
    g.z = a0.z * x2.x + h.z * x2.y;

    return 130.0 * dot(m, g);
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}


vec2 smoothstep2(vec2 t) {
    return t * t * (3.0 - 2.0 * t);
}


float value_noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = smoothstep2(f);

    return mix(
        mix(a, b, u.x),
        mix(c, d, u.x),
        u.y
    );
}


vec2 hash2(vec2 p) {
    p = vec2(
        dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3))
    );
    return fract(sin(p) * 43758.5453);
}


float voronoi(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float min_dist = 1.0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash2(i + neighbor);

            vec2 diff = neighbor + point - f;

            float dist = length(diff);

            min_dist = min(min_dist, dist);
        }
    }

    return min_dist; 
}




void fragment() {
	//fallback (sets to image if color is not set)
	vec4 tex_color = texture(TEXTURE, UV);
	COLOR = tex_color;
	
	vec2 uv = UV*_noiseScale;
	
	if(_shaderPass == 0){
		COLOR = vec4(uv,0.0,1.0);
	}
	else if(_shaderPass == 1){
		float value = whiteNoise(uv);
		COLOR = vec4(value,value,value,1.0);
	}
	else if(_shaderPass == 2){
		float value = simplexNoise(uv);
		COLOR = vec4(value,value,value,1.0);
	}
	else if(_shaderPass == 3){
		float value = value_noise(uv);
		COLOR = vec4(value,value,value,1.0);
	}
	else if(_shaderPass == 4){
		float value = voronoi(uv);
		COLOR = vec4(value,value,value,1.0);
	}

			
}
