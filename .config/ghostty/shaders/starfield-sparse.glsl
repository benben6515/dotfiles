// starfield-sparse.glsl — customized starfield (~10-100 stars)
// Tunables:
//   repeats    = grid divisions (cells per layer ≈ repeats² × aspect)
//   layers     = number of star layers
//   starChance = probability a cell keeps its star
// ≈ stars on screen = repeats² × aspect × layers × starChance
//   (5² × 1.6 × 3 × 0.5 ≈ 60 on a 16:10 window)

// transparent background
const bool transparent = false;

// terminal contents luminance threshold to be considered background (0.0 to 1.0)
const float threshold = 0.15;

// divisions of grid (was 30 in the original)
const float repeats = 5.;

// number of layers (was 21 in the original)
const float layers = 3.;

// fraction of cells that actually show a star
const float starChance = 0.5;

// flight speed multiplier (1./3. = 3x slower than original)
const float speed = 1. / 3.;

// star colors
const vec3 white = vec3(1.0);

float luminance(vec3 color) {
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

float N21(vec2 p) {
    p = fract(p * vec2(233.34, 851.73));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}

vec2 N22(vec2 p) {
    float n = N21(p);
    return vec2(n, N21(p + n));
}

mat2 scale(vec2 _scale) {
    return mat2(_scale.x, 0.0,
        0.0, _scale.y);
}

vec3 stars(vec2 uv, float offset) {
    float timeScale = -(iTime * speed + offset) / layers;
    float trans = fract(timeScale);
    float newRnd = floor(timeScale);
    vec3 col = vec3(0.);

    // Translate uv then scale for center
    uv -= vec2(0.5);
    uv = scale(vec2(trans)) * uv;
    uv += vec2(0.5);

    // Create square aspect ratio
    uv.x *= iResolution.x / iResolution.y;

    // Create boxes
    uv *= repeats;

    // Get position
    vec2 ipos = floor(uv);

    // Sparse: randomly skip cells (stable within one flight cycle)
    if (N21(newRnd + ipos * (offset + 1.) + 7.77) > starChance) {
        return vec3(0.);
    }

    // Return uv as 0 to 1
    uv = fract(uv);

    // Calculate random xy and size
    vec2 rndXY = N22(newRnd + ipos * (offset + 1.)) * 0.9 + 0.05;
    float rndSize = N21(ipos) * 300. + 600.;

    vec2 j = (rndXY - uv) * rndSize;
    float sparkle = 1. / dot(j, j);

    // Set stars to be pure white
    col += white * sparkle;

    col *= smoothstep(1., 0.8, trans);
    return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / iResolution.xy;

    vec3 col = vec3(0.);

    for (float i = 0.; i < layers; i++) {
        col += stars(uv, i);
    }

    // Sample the terminal screen texture including alpha channel
    vec4 terminalColor = texture(iChannel0, uv);

    if (transparent) {
        col += terminalColor.rgb;
    }

    // Make a mask that is 1.0 where the terminal content is not black
    float mask = 1 - step(threshold, luminance(terminalColor.rgb));

    vec3 blendedColor = mix(terminalColor.rgb, col, mask);

    // Apply terminal's alpha to control overall opacity
    fragColor = vec4(blendedColor, terminalColor.a);
}
