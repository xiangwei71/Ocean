Shader "Hidden/PhillipsSpectrum_v2"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_wind("wind dir",Vector) = (1.,0.,0.,0.)
		_A("A", Float) = 2.

		_V("wind Veloicty", Float) = 1000.
		_g("g", Float) = 9.8
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
				#include "PhillipsSpectrum.cginc"

				//公式從這裡看來的
				//https://zhuanlan.zhihu.com/p/64414956

				float2 _wind;
				float _A;
				float _V;
				float _g;
				float _L;

				sampler2D _MainTex;
				float4 _MainTex_ST;

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

				float2 frag(v2f i) : SV_Target
				{
					_wind = normalize(_wind);
					_L = _V * _V / _g;
					float2 uv = i.uv;
					float2 n = uv;

					// 轉成整數索引 0~FFT_h-1，比如說0~511
					int2 index = uv_to_uint_index(i.uv);

					// index to 2PI * h/2 ~ 2PI *(h/2-1)
					//這等於作了Shift，所以之後要自己Shift回來
					index -= FFT_h * 0.5;
					float2 k = FFT_2_PI * index;

					k *= detail_factor;

					//float t = 0.;
					float t =  0.02* _Time.y;

					return h(n, k, t,_L,_wind,_A,_g);
				}
				ENDCG
			}
		}
}