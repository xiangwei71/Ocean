#define FFT_n 9 // 2^FFT_n = FFT_h
#define  FFT_h 512

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
	uint bite[FFT_n] = { 0,0,0,0,0,0,0,0,0 };
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