Shader "Hidden/multiply_weight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "FFT_Utils.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
			uint _order;

			float2 frag(v2f i) : SV_Target
			{
				// 轉成整數索引
				uint2 index = uv_to_uint_index(i.uv);

				uint h = pow(2,_order + 1);
				uint hh = 0.5 * h;

				uint I = index.y % h;
				uint power_of_W = floor(I / hh) * (I % hh) * pow(2, FFT_n - 1 - _order);

				//return float2(0, power_of_W);
				float2 weight = W(power_of_W, FFT_h);
				return weight;
				float2 c = tex2D(_MainTex, i.uv).rg;
				return complex_multiply(weight, c);
            }
            ENDCG
        }
    }
}
