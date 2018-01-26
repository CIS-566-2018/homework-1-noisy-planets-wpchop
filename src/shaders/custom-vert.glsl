#version 300 es

//This is a vertex shader. While it is called a "shader" due to outdated conventions, this file
//is used to apply matrix transformations to the arrays of vertex data passed to it.
//Since this code is run on your GPU, each vertex is transformed simultaneously.
//If it were run on your CPU, each vertex would have to be processed in a FOR loop, one at a time.
//This simultaneous transformation allows your program to run much faster, especially when rendering
//geometry with millions of vertices.

uniform mat4 u_Model;       // The matrix that defines the transformation of the
                            // object we're rendering. In this assignment,
                            // this will be the result of traversing your scene graph.

uniform mat4 u_ModelInvTr;  // The inverse transpose of the model matrix.
                            // This allows us to transform the object's normals properly
                            // if the object has been non-uniformly scaled.

uniform mat4 u_ViewProj;    // The matrix that defines the camera's transformation.
                            // We've written a static matrix for you to use for HW2,
                            // but in HW3 you'll have to generate one yourself

uniform float u_Time;       // Time variable to pass to sinusoid functions.

in vec4 vs_Pos;             // The array of vertex positions passed to the shader

in vec4 vs_Nor;             // The array of vertex normals passed to the shader

in vec4 vs_Col;             // The array of vertex colors passed to the shader.

out vec4 fs_Nor;            // The array of normals that has been transformed by u_ModelInvTr. This is implicitly passed to the fragment shader.
out vec4 fs_LightVec;       // The direction in which our virtual light lies, relative to each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Col;            // The color of each vertex. This is implicitly passed to the fragment shader.
out vec4 fs_Pos;

const vec4 lightPos = vec4(5, 5, 3, 1); //The position of our virtual light, which is used to compute the shading of
                                        //the geometry in the fragment shader.

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

    for (int i = 0; i < 4; i++) {
        float frequency = pow(2.0,float(i)) / 4.0;
        float amplitude = pow(persistence, float(i)) / 1.0;
        total += sampleSimplexNoise(x * frequency, y * frequency, z * frequency) * amplitude;
    }
    return -clamp(total, 0.0, 0.05);
}

void main()
{
    vec4 blue = vec4(0.0,0.0,1.0,1.0);
    vec4 green = vec4(0.29,0.43,0.25,1.0);
    fs_Col = vs_Col;                         // Pass the vertex colors to the fragment shader for interpolation

    mat3 invTranspose = mat3(u_ModelInvTr);
    fs_Nor = normalize(vec4(invTranspose * vec3(vs_Nor), 0));          // Pass the vertex normals to the fragment shader for interpolation.
                                                            // Transform the geometry's normals by the inverse transpose of the
                                                            // model matrix. This is necessary to ensure the normals remain
                                                            // perpendicular to the surface after the surface is transformed by
                                                            // the model matrix.
    fs_Col = vec4(normalize(fs_Nor).xyz,1);
    vec4 pos = u_Model * vs_Pos;
    fs_Pos = pos;
    float noise = simplexNoise(pos.x, pos.y, pos.z);
    vec4 offset = noise * fs_Nor;
    if (noise + 0.05 > 0.0001) {
        fs_Col = green;
    } else {
        fs_Col = blue;
    }

    // No offset, modelspace
    vec4 modelposition = u_Model * vs_Pos + offset; // Temporarily store the transformed vertex positions for use below

    fs_LightVec = lightPos - modelposition;  // Compute the direction in which the light source lies

    gl_Position = u_ViewProj * modelposition;// gl_Position is a built-in variable of OpenGL which is
                                             // used to render the final positions of the geometry's vertices
}