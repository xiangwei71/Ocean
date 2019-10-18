Shader "Unlit/PhillipsSpectrum"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_wind("wind dir",Vector) = (1.,0.,0.,0.)
		_A("A", Float) = 2.

		_V("wind Veloicty", Float) = 1000.
		_g("g", Float) = 9.8
		_L("L",Float) = 102040.816327// (1000. * 1000. / 9.8)
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "FFT_Utils.cginc"

			//公式從這裡看來的
			//https://zhuanlan.zhihu.com/p/64414956

			float2 _wind;
			float _A;
			float _V;
			float _g;
			float _L;

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float random(float2 v)
			{
				return frac(sin(dot(v, float2(1113.,11.5))) * 43758.54534);
			}

			float random_clamp(float2 v) {
				// need clamp beacuse 
				// https://www.geogebra.org/m/dpvqeczu
				return clamp(random(v),0.001,1.);
			}

			// https://www.geogebra.org/m/dpvqeczu
			float2 gaussian_distribution(float2 u) {
				float u1 = u.x;
				float u2 = u.y;

				// Box-Muller
				// https://zhuanlan.zhihu.com/p/67776340
				float r = sqrt(-2. * log(u1));
				return float2(r * cos(FFT_2_PI * u2),r * sin(FFT_2_PI * u2));
			}

			// https://zhuanlan.zhihu.com/p/64414956
			float Pn(float2 k,float K) {
				float K2 = K * K;
				float KL = K * _L;
				float dot_k_wind = abs(dot(k,_wind));
				return  _A / (K2 * K2) * exp(-1. / (KL * KL)) * dot_k_wind * dot_k_wind;
			}

			float2 h0(float2 k, float2 E,float K) {
				float S = sqrt(Pn(k,K) / 2.);
				//return float2(S);
				return S * E;
			}

			float2 h0_conjugate(float2 k, float2 E,float K) {
				float2 c_h0 = h0(k,E,K);
				return float2(c_h0.x,-c_h0.y);
			}

			float w(float k) {
				return sqrt(_g * k);
			}

			float2 e_i(float x) {
				return float2(cos(x),sin(x));
			}

			// n 0.~1.
			float2 h(float2 n, float2 k,float t) {
				float2 t1 = k + t;
				float range = 10.;
				float2 offset1 = t1 % range;
				float2 offset2 = t1 + float2(0.45,0.99) % range;
				float2 offset3 = t1 + float2(0.15,-0.6) % range;
				float2 offset4 = t1 + float2(-0.9,0.01) % range;

				float2 E1 = gaussian_distribution(float2(random_clamp(offset1),random_clamp(offset2)));
				float2 E2 = gaussian_distribution(float2(random_clamp(offset3),random_clamp(offset4)));

				//return offset1;
				//return E2;    

				float K = length(k);
				K = (K > 0.0001) ? K : 0.0001;
				//return e_i(-w(K)*t);
				//return complex_multiply(h0(k,E1,K) , e_i(w(K)*t));
				//return complex_multiply(h0_conjugate(-k,E2,K) , e_i(-w(K)*t));
				return complex_multiply(h0(k,E1,K) , e_i(w(K) * t))
				+ complex_multiply(h0_conjugate(-k,E2,K) , e_i(-w(K) * t));
			}

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;

				//float t = 0.;
				float t = FFT_2_PI *_Time.y;
				float2 k = uv * 2. - 1.;// 0~1 to -1~1
				return float4(h(uv, k, t), 0., 1.);
				//return float4(t,0., 0., 1.);
			}
			ENDCG
		}
	}
}