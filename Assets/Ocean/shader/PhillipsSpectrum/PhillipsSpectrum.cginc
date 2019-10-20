#include "../FFT/FFT_Utils.cginc"

#define detail_factor 10

//formula is get from here
//https://zhuanlan.zhihu.com/p/64414956

float random(float2 v)
{
	//return frac(sin(dot(v, float2(1113.,11.5))) * 43758.54534);
	// this can get diffrent viusal result
	//float F = 0.01,sedd_x = 11,seed_y = 11.5;
	float F = 0.1, sedd_x = 11, seed_y = 11.5;

	return frac(sin(F * dot(v, float2(sedd_x, seed_y))) * 43758.54534);
}

float random_clamp(float2 v) {
	// need clamp beacuse 
	// https://www.geogebra.org/m/dpvqeczu
	return clamp(random(v), 0.001, 1.);
}

// https://www.geogebra.org/m/dpvqeczu
float2 gaussian_distribution(float2 u) {
	float u1 = u.x;
	float u2 = u.y;

	// Box-Muller
	// https://zhuanlan.zhihu.com/p/67776340
	float r = sqrt(-2. * log(u1));
	return float2(r * cos(FFT_2_PI * u2), r * sin(FFT_2_PI * u2));
}

// https://zhuanlan.zhihu.com/p/64414956
float Pn(float2 k, float K, float L,float2 wind,float A) {
	float K2 = K * K;
	float KL = K * L;
	float dot_k_wind = abs(dot(k, wind));
	float power = 0.5;
	return  A / (K2 * K2) * exp(-1. / (KL * KL)) * pow(dot_k_wind, power);
}

float2 h0(float2 k, float2 E, float K, float L, float2 wind,  float A) {
	float S = sqrt(Pn(k, K, L, wind,A) / 2.);
	//return float2(S, S);
	return S * E;
}

float2 h0_conjugate(float2 k, float2 E, float K, float L, float2 wind,float A) {
	float2 c_h0 = h0(k, E, K, L, wind,A);
	return float2(c_h0.x, -c_h0.y);
}

float w(float k, float g) {
	return sqrt(g * k);
}

float2 e_i(float x) {
	return float2(cos(x), sin(x));
}

// n 0.~1.
float2 h(float2 n, float2 k, float t, float L,float2 wind, float A,float g) {
	float2 t1 = n;
	float range = 10;
	float2 offset1 = t1 % range;
	float2 offset2 = t1 + float2(0.45, 0.99) % range;
	float2 offset3 = t1 + float2(0.15, -0.6) % range;
	float2 offset4 = t1 + float2(-0.9, 0.01) % range;

	float2 E1 = gaussian_distribution(float2(random_clamp(offset1), random_clamp(offset2)));
	float2 E2 = gaussian_distribution(float2(random_clamp(offset3), random_clamp(offset4)));
	//float2 E1 = float2(random_clamp(offset1), random_clamp(offset2));
	//float2 E2 = float2(random_clamp(offset3), random_clamp(offset4));

	//return offset1;
	//return E2;    

	float K = length(k);
	K = (K > 0.0001) ? K : 0.0001;

	return complex_multiply(h0(k, E1, K, L, wind, A), e_i(w(K, g) * t));
	+ complex_multiply(h0_conjugate(-k, E2, K, L, wind, A), e_i(-w(K, g) * t));
}