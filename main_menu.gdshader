shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 0.42;
uniform float dust_speed : hint_range(0.0, 2.0) = 0.35;
uniform float dust_opacity : hint_range(0.0, 1.0) = 0.25;


// RANDOM
float hash21(vec2 p)
{
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}


// DUST
float dust_layer(
    vec2 uv,
    float scale,
    float speed,
    float particle_size,
    float seed
)
{
    vec2 grid = uv * scale;

    vec2 cell = floor(grid);
    vec2 local = fract(grid);

    float rnd = hash21(cell + seed);

    // LEBIH BANYAK PARTIKEL
    if (rnd < 0.60)
        return 0.0;

    // Posisi awal
    float px = hash21(cell + seed + 13.7);
    float py = hash21(cell + seed + 37.2);

    // Gerakan angin
    px += TIME * speed * (0.25 + rnd * 0.35);

    // Sedikit turun
    py += TIME * speed * 0.035;

    px = fract(px);
    py = fract(py);

    vec2 particle_pos = vec2(px, py);

    vec2 d = local - particle_pos;

    // Arah terbang
    d.x *= 1.8;

    float dist = length(d);

    float size =
        particle_size * (1.00 + rnd * 0.8);

    // Partikel BULAT halus
    float particle =
        1.0 - smoothstep(
            size * 0.15,
            size,
            dist
        );

    particle *= 0.25 + rnd * 0.9;

    return particle;
}


void fragment()
{
    vec4 tex = texture(TEXTURE, UV);

    // =================================
    // BACKGROUND GELAP
    // =================================

    vec3 col = tex.rgb;

    col *= 1.0 - darkness;


    // =================================
    // VIGNETTE
    // =================================

    vec2 centered = UV - vec2(0.5);

    float vignette =
        smoothstep(
            0.25,
            0.8,
            length(centered)
        );

    col *= 1.0 - vignette * 0.35;


    // =================================
    // BANYAK DEBU
    // =================================

    float dust1 = dust_layer(
        UV,
        90.0,
        dust_speed,
        0.045,
        50.0
    );

    float dust2 = dust_layer(
        UV,
        55.0,
        dust_speed * 0.75,
        0.060,
        .0
    );

    float dust3 = dust_layer(
        UV,
        28.0,
        dust_speed * 0.5,
        0.075,
        100.0
    );


    float dust =
        dust1 * 0.50 +
        dust2 * 0.70 +
        dust3 * 0.85;


    // =================================
    // WARNA DEBU
    // =================================

    vec3 dust_color =
        vec3(0.72, 0.60, 0.43);


    col = mix(
        col,
        dust_color,
        dust * dust_opacity
    );


    COLOR = vec4(col, tex.a);
}