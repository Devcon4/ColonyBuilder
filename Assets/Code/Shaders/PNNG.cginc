
// Upgrade NOTE: excluded shader from DX11, Xbox360, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 xbox360 gles

// precomputed array.
int p[] = { 151,160,137,91,90,15,
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
138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180 
};

// Extrapolation f(t) = 6t^5 - 15t^4 + 10t^3
float fade(float t) { return t * t * t * (t * (t * 6 - 15) + 10); }

// Dot product of two points.
float lerp(float t, float a, float b) { return a + t * (b - a); }

// Calculates gradient vector.
float grad(int hash, float x, float y, float z, float w) {
	int h = hash & 15;
	float u = h < 8 /* 0b1000 */ ? x : y;
	float v = h < 4 ? y : h == 12 || h == 14 ? x : h > 10 ? z : w;
	return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

// Calculates gradient vector.
float grad(int hash, float x, float y, float z) {
	int h = hash & 15;
	float u = h < 8 /* 0b1000 */ ? x : y;
	float v = h < 4 ? y : h == 12 || h == 14 ? x : z;

	return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

// Calculates gradient vector.
float grad(int hash, float x, float y) {
	int h = hash & 15;
	float u = h < 8 ? x : y,
		v = h < 4 ? x / 2 : h > 12 ? y / 2 : x;
	return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

// Calculates gradient vector.
float grad(int hash, float x) {
	int h = hash & 15;
	float u = h < 8 ? x : -x,
		v = h < 4 ? x / 2 : -x / 2;
	return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
}

/// <summary>
/// PerlinNoiseV2_0.
/// Noise using an improved algorithm.
/// </summary>
/// <param name="x">X coordinate.</param>
/// <param name="y">Y coordinate.</param>
/// <param name="z">Z coordinate.</param>
/// <returns>Returns noise.</returns>
float Noise(float x, float y, float z, float w) {
	int X = int(floor(x)) & 255,
		Y = int(floor(y)) & 255,
		Z = int(floor(z)) & 255,
		W = int(floor(w)) & 255;
	x -= int(floor(x));
	y -= int(floor(y));
	z -= int(floor(z));
	w -= int(floor(w));
	float u = fade(x),
		v = fade(y),
		t = fade(z),
		s = fade(w);
	int A = p[x] + Y,
		B = p[x + 1] + Y,
		AA = p[A] + Z,
		AB = p[A + 1] + Z,
		BA = p[B] + Z,
		BB = p[B + 1] + Z,
		AAA = p[AA] + W,
		AAB = p[AA + 1] + W,
		ABA = p[AB] + W,
		ABB = p[AB + 1] + W,
		BAA = p[BA] + W,
		BAB = p[BA + 1] + W,
		BBA = p[BB] + W,
		BBB = p[BB + 1] + W;

	return lerp(s, lerp(t, lerp(v, lerp(u, grad(p[AAA  ], x,     y,     z,     w),
										   grad(p[AAB  ], x - 1, y,     z,     w)),
								   lerp(u, grad(p[ABA  ], x,     y - 1, z,     w),
										   grad(p[ABB  ], x - 1, y - 1, z,     w))),
						   lerp(v, lerp(u, grad(p[BAA  ], x,     y,     z - 1, w),
										   grad(p[BAB  ], x - 1, y,     z - 1, w)),
								   lerp(u, grad(p[BBA  ], x,     y - 1, z - 1, w),
										   grad(p[BBB  ], x - 1, y - 1, z - 1, w)))),
					lerp(t, lerp(v,lerp(u, grad(p[AAA+1], x,     y,     z,     w - 1),
										   grad(p[AAB+1], x - 1, y,     z,     w - 1)),
								   lerp(u, grad(p[ABA+1], x,     y - 1, z,     w - 1),
										   grad(p[ABB+1], x - 1, y - 1, z,     w - 1))),
						   lerp(v, lerp(u, grad(p[BAA+1], x,     y,     z - 1, w - 1),
										   grad(p[BAB+1], x - 1, y,     z - 1, w - 1)),
								   lerp(u, grad(p[BBA+1], x,     y - 1, z - 1, w - 1),
										   grad(p[BBB+1], x - 1, y - 1, z - 1, w - 1)))));
}

/// <summary>
/// PerlinNoiseV2_0.
/// Noise using an improved algorithm.
/// </summary>
/// <param name="x">X coordinate.</param>
/// <param name="y">Y coordinate.</param>
/// <param name="z">Z coordinate.</param>
/// <returns>Returns noise.</returns>
float Noise(float x, float y, float z) {
	int X = int(floor(x)) & 255,
		Y = int(floor(y)) & 255,
		Z = int(floor(z)) & 255;
	x -= int(floor(x));
	y -= int(floor(y));
	z -= int(floor(z));
	float u = fade(x),
		v = fade(y),
		w = fade(z);
	int A = p[X] + Y, 
		AA = p[A] + Z, 
		AB = p[A + 1] + Z,      
		B = p[X + 1] + Y, 
		BA = p[B] + Z, 
		BB = p[B + 1] + Z;

	return lerp(w, lerp(v, lerp(u,  grad(p[AA  ], x,     y,     z),
									grad(p[BA  ], x - 1, y,     z)),
							lerp(u, grad(p[AB  ], x,     y - 1, z),
									grad(p[BB  ], x - 1, y - 1, z))),
					lerp(v, lerp(u, grad(p[AA+1], x,     y,     z - 1),
									grad(p[BA+1], x - 1, y,     z - 1)),
							lerp(u, grad(p[AB+1], x,     y - 1, z - 1),
									grad(p[BB+1], x - 1, y - 1, z - 1))));
}

/// <summary>
/// PerlinNoiseV2_0.
/// Noise using an improved algorithm.
/// </summary>
/// <param name="x">X coordinate.</param>
/// <param name="y">Y coordinate.</param>
/// <returns>Returns noise.</returns>
float Noise(float x, float y) {
	int X = int(floor(x)) & 255,
		Y = int(floor(y)) & 255;
	x -= int(floor(x));
	y -= int(floor(y));
	float u = fade(x),
		v = fade(y);
	int A = p[X] + Y,
		B = p[X + 1];

	return lerp(v, lerp(u, grad(p[A], x, y),
							grad(p[A + 1], x - 1, y)),
					lerp(u, grad(p[B], x, y - 1),
							grad(p[B + 1], x - 1, y - 1)));
}

float FractalNoise(float x, float y, float z, int octNum, float frq, float amp)
{
	float gain = 1.0;
	float sum = 0.0;

	for (int i = 0; i < octNum; i++)
	{
		sum += Noise(x*gain / frq, y*gain / frq, z*gain / frq) * amp / gain;
		gain *= 2.0;
	}
	return sum;
}