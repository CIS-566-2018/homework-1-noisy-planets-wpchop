#version 300 es

// This is a fragment shader. If you've opened this file first, please
// open and read lambert.vert.glsl before reading on.
// Unlike the vertex shader, the fragment shader actually does compute
// the shading of geometry. For every pixel in your program's output
// screen, the fragment shader is run for every bit of geometry that
// particular pixel overlaps. By implicitly interpolating the position
// data passed into the fragment shader by the vertex shader, the fragment shader
// can compute what color to apply to its pixel based on things like vertex
// position, light position, and vertex color.
precision highp float;

uniform vec4 u_Color; // The color with which to render this instance of geometry.
uniform vec4 u_Sea;
uniform vec4 u_Land;
uniform mat4 u_viewMatrix;

// These are the interpolated values out of the rasterizer, so you can't know
// their specific values without knowing the vertices that contributed to them
in vec4 fs_Nor;
in vec4 fs_LightVec;
in vec4 fs_Col;
in vec4 fs_Pos;

out vec4 out_Col; // This is the final output color that you will see on your
                  // screen for the pixel that is currently being processed.

const vec3 grad3[12] = vec3[12] (vec3(1,1,0),vec3(-1,1,0),vec3(1,-1,0),vec3(-1,-1,0),
    vec3(1,0,1),vec3(-1,0,1),vec3(1,0,-1),vec3(-1,0,-1),
    vec3(0,1,1),vec3(0,-1,1),vec3(0,1,-1),vec3(0,-1,-1));

const vec4 grad4[32] = vec4[32] (vec4(0,1,1,1), vec4(0,1,1,-1), vec4(0,1,-1,1), 
    vec4(0,1,-1,-1), vec4(0,-1,1,1), vec4(0,-1,1,-1), vec4(0,-1,-1,1), vec4(0,-1,-1,-1), 
    vec4(1,0,1,1), vec4(1,0,1,-1), vec4(1,0,-1,1), vec4(1,0,-1,-1), vec4(-1,0,1,1), 
    vec4(-1,0,1,-1), vec4(-1,0,-1,1), vec4(-1,0,-1,-1), vec4(1,1,0,1), vec4(1,1,0,-1), 
    vec4(1,-1,0,1), vec4(1,-1,0,-1), vec4(-1,1,0,1), vec4(-1,1,0,-1), vec4(-1,-1,0,1), 
    vec4(-1,-1,0,-1), vec4(1,1,1,0), vec4(1,1,-1,0), vec4(1,-1,1,0), vec4(1,-1,-1,0), 
    vec4(-1,1,1,0), vec4(-1,1,-1,0), vec4(-1,-1,1,0), vec4(-1,-1,-1,0));

const int p[256] = int[256] (151,160,137,91,90,15,
 131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
 190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
 88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
 77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
 102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
 135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
 5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
 223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
 129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
 251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
 49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
 138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180);

 const vec4 simplex[64] = vec4[64] (vec4(0,1,2,3),vec4(0,1,3,2),vec4(0,0,0,0),
    vec4(0,2,3,1),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(1,2,3,0), 
    vec4(0,2,1,3),vec4(0,0,0,0),vec4(0,3,1,2),vec4(0,3,2,1),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(0,0,0,0),vec4(1,3,2,0), vec4(0,0,0,0),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(1,2,0,3),vec4(0,0,0,0),vec4(1,3,0,2),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(0,0,0,0),vec4(2,3,0,1),vec4(2,3,1,0), vec4(1,0,2,3),
    vec4(1,0,3,2),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(2,0,3,1),
    vec4(0,0,0,0),vec4(2,1,3,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0), 
    vec4(2,0,1,3),vec4(0,0,0,0),vec4(0,0,0,0),vec4(0,0,0,0),vec4(3,0,1,2),
    vec4(3,0,2,1),vec4(0,0,0,0),vec4(3,1,2,0), vec4(2,1,0,3),vec4(0,0,0,0),
    vec4(0,0,0,0),vec4(0,0,0,0),vec4(3,1,0,2),vec4(0,0,0,0),
    vec4(3,2,0,1),vec4(3,2,1,0));
 
float sampleSimplexNoise(float xin, float yin, float zin) {
    float n0, n1, n2, n3;
    float F3 = 1.0/3.0;
    float s = (xin + yin + zin) * F3;
    int i = int(floor(xin + s));
    int j = int(floor(yin + s));
    int k = int(floor(zin + s));

    const float G3 = 1.0/6.0;
    float t = float(i + j + k) * G3;
    float X0 = float(i) - t;
    float Y0 = float(j) - t;
    float Z0 = float(k) - t;
    float x0 = xin - X0;
    float y0 = yin - Y0;
    float z0 = zin - Z0;

    int i1, j1, k1; // Offsets for second corner of simplex in (i,j,k) coords
    int i2, j2, k2; // Offsets for third corner of simplex in (i,j,k) coords

    if(x0>=y0) {
        if(y0>=z0) { // X Y Z order
            i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; 
        } else if(x0>=z0) { 
            i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; // X Z Y order
        } else { 
            i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; // Z X Y order
        } 
        }
    else { // x0<y0
        if(y0<z0) { 
            i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; // Z Y X order
        } else if (x0<z0) { 
            i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; // Y Z X order
        } else { 
            i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; // Y X Z order
        } 
    }

    float x1 = x0 - float(i1) + G3; // Offsets for second corner in (x,y,z) coords
    float y1 = y0 - float(j1) + G3;
    float z1 = z0 - float(k1) + G3;
    float x2 = x0 - float(i2) + 2.0*G3; // Offsets for third corner in (x,y,z) coords
    float y2 = y0 - float(j2) + 2.0*G3;
    float z2 = z0 - float(k2) + 2.0*G3;
    float x3 = x0 - float(1.0) + 3.0*G3; // Offsets for last corner in (x,y,z) coords
    float y3 = y0 - float(1.0) + 3.0*G3;
    float z3 = z0 - float(1.0) + 3.0*G3;

    int ii = i & 255;
    int jj = j & 255;
    int kk = k & 255;

    int gi0 = p[255 & ii+p[255 & jj+p[255 & kk]]] % 12;
    int gi1 = p[255 & ii+i1+p[255 & jj+j1+p[255 & kk+k1]]] % 12;
    int gi2 = p[255 & ii+i2+p[255 & jj+j2+p[255 & kk+k2]]] % 12;
    int gi3 = p[255 & ii+1+p[255 & jj+1+p[255 & kk+1]]] % 12;

    float t0 = 0.5 - x0*x0 - y0*y0 - z0*z0;
    if (t0 < 0.0) { 
        n0 = 0.0;
    } else {
        t0 *= t0;
        n0 = t0 * t0 * dot(grad3[gi0], vec3(x0, y0, z0));
    }
    float t1 = 0.5 - x1*x1 - y1*y1 - z1*z1;
    if (t1 < 0.0) {
        n1 = 0.0;
    } else {
        t1 *= t1;
        n1 = t1 * t1 * dot(grad3[gi1], vec3(x1, y1, z1));
    }
    float t2 = 0.5 - x2*x2 - y2*y2 - z2*z2;
    if (t2 < 0.0) {
        n2 = 0.0;
    } else {
        t2 *= t2;
        n2 = t2 * t2 * dot(grad3[gi2], vec3(x2, y2, z2));
    }
    float t3 = 0.5 - x3*x3 - y3*y3 - z3*z3;
    if (t3 < 0.0) {
        n3 = 0.0;
    } else {
        t3 *= t3;
        n3 = t3 * t3 * dot(grad3[gi3], vec3(x3, y3, z3));
    }

    float noise = max(0.0,5.0 * (n0 + n1 + n2 + n3));
    return clamp(noise, 0.0, 0.2);
    //return 0.05 * sin(0.05 * u_Time) + 1.0;
}

float simplexNoise(float x, float y, float z) {
    float total = 0.0;
    float persistence = 1.5;

    for (int i = 0; i < 5; i++) {
        float frequency = pow(2.0,float(i)) / 4.0;
        float amplitude = pow(persistence, float(i)) / 1.0;
        total += sampleSimplexNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    }
    return - clamp(total, -0.05, 0.1);
}


void main()
{
    vec3 fragColor = vec3(0.0);

    // Determining the surface normal 
    float noise = simplexNoise(fs_Pos.x, fs_Pos.y, fs_Pos.z);
    vec3 pos = vec3(fs_Pos + noise * fs_Nor);
    vec3 surfaceNormal = normalize(- cross( vec3(dFdx(pos)), vec3(dFdy(pos))));

    // Material base color (before shading)
    vec4 diffuseColor = fs_Col;

    if (!(noise + 0.1 > 0.0001)) {
        vec3 albedo = vec3(0.2, 0.2, 0.2);
         // Ocean
        vec3 lightDir = vec3(fs_LightVec);
        float NdotL = clamp(dot(surfaceNormal, lightDir), 0.1, 1.0);

        mat4 invViewMatrix = inverse(u_viewMatrix);
        vec4 cameraWorldPos = invViewMatrix * vec4(0.0, 0.0, 0.0, 1.0);
        vec3 V = normalize(cameraWorldPos.xyz - pos);
        vec3 H = normalize(lightDir + V);
        float NdotH = max(dot(H, surfaceNormal), 0.0);
        float specular = pow(NdotH, 100.0);
        fragColor += (albedo + vec3(specular)) * NdotL;

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(vec4(surfaceNormal,0.0)), normalize(fs_LightVec));
        // Avoid negative lighting values
       // diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        fragColor += 0.8 * diffuseColor.rgb * lightIntensity;
        // Compute final shaded color
        out_Col = vec4(fragColor, diffuseColor.a);

        return;
    }

        // Calculate the diffuse term for Lambert shading
        float diffuseTerm = dot(normalize(vec4(surfaceNormal,0.0)), normalize(fs_LightVec));
        // Avoid negative lighting values
        diffuseTerm = clamp(diffuseTerm, 0.0, 1.0);

        float ambientTerm = 0.2;

        float lightIntensity = diffuseTerm + ambientTerm;   //Add a small float value to the color multiplier
                                                            //to simulate ambient lighting. This ensures that faces that are not
                                                            //lit by our point light are not completely black.

        // Compute final shaded color
        out_Col = vec4(diffuseColor.rgb * lightIntensity, diffuseColor.a);
}
