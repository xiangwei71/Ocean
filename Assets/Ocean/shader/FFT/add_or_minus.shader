Shader "Hidden/add_or_minus"
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
			uint _order; // 2^n= h ,_order < n

            float2 frag (v2f i) : SV_Target
            {
				// 轉成整數索引
				uint2 index = uv_to_uint_index(i.uv);
				uint x = index.x;
				uint y = index.y;

				uint offset = pow(2, _order);

				float2 des;
				if (floor(y / offset) % 2 == 0) {
					// des[x][y] = src[x][y] + src[x][y + offset]

					//shader裡uv原點應該是在左下角，不過這裡把uv原點想成是在左上角
					float2 uv_1 = index_to_uv(index);
					float2  uv_2 = index_to_uv(uint2(index.x,index.y+offset));

					float2 value_1 = tex2D(_MainTex, uv_1).rg;
					float2 value_2 = tex2D(_MainTex, uv_2).rg;
					des = value_1 + value_2;
				}
				else {
					// des[x][y] = - src[x][y] + src[x][y - offset] 
					float2 uv_1 = index_to_uv(index);
					float2  uv_2 = index_to_uv(uint2(index.x, index.y - offset));

					float2 value_1 = tex2D(_MainTex, uv_1).rg;
					float2 value_2 = tex2D(_MainTex, uv_2).rg;
					des = -value_1 + value_2;
				}

                return des;
            }
            ENDCG
        }
    }
}
