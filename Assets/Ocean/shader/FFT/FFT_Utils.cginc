#define FFT_n 9 // 2^FFT_n = FFT_h
#define  FFT_h 512
#define FFT_2_PI 6.28
#define detail_factor  10

uint2 uv_to_uint_index(float2 uv) {
	float2 space = 1. / FFT_h;
	float2 offset = space * 0.5;
	uint2 index = (uv - offset) / space;
	return index;
}

float2 index_to_uv(uint2 index) {
	float2 space = 1. / FFT_h;
	float2 offset = space * 0.5;
	return index * space + offset;
}

uint bit_inverse(uint number) {
	//轉成2進位
	// https://www.youtube.com/watch?v=h1xB2soEcug&list=LLtNG9vPhMZxQfxCUCfcxLWg&index=2&t=0s
	uint bite[FFT_n] ;
	int y;
	for (y= 0; y < FFT_n; ++y)
	{
		bite[y] = number % 2;
		number = floor(number / 2);
	}

	//bite Inverse 
	//組回10進位
	uint bite_inverse_number = 0;
	for (y = 0; y < FFT_n; ++y) {
		bite_inverse_number += pow(2, FFT_n - 1 - y) * bite[y];
	}

	return bite_inverse_number;
}

float2 complex_multiply(float2 c1, float2 c2) {
	float x = c1.x;
	float y = c1.y;
	float a = c2.x;
	float b = c2.y;
	return float2(a * x - b * y, a * y + b * x);
}

/**
 *														power
 * @param {*} power		\  /\  /
 * @param {*} N				 \/  \/  N
 */
float2 W(uint power, uint N,float rotate) {
	float theda = power * (-FFT_2_PI*rotate) / N;
	return float2( cos(theda), sin(theda) );
}