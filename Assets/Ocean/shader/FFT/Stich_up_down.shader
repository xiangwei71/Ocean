Shader "Hidden/Stich_up_down"
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

			#include "FFT_Utils.cginc"
            #include "UnityCG.cginc"

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

            float2 frag (v2f i) : SV_Target
            {
				float h = tex2D(_MainTex, i.uv).r;
				uint2 index = uv_to_uint_index(i.uv);

				float2 neighbor_uv = i.uv;
				if (index.y == 0) {
					neighbor_uv = index_to_uv(uint2(index.x,FFT_h - 1));
				}
				else if (index.y == FFT_h - 1) {
					neighbor_uv = index_to_uv(uint2(index.x,0 ));
				}

				float2 neighbor_h = tex2D(_MainTex, neighbor_uv).r;
				float final_h = (h + neighbor_h) * 0.5;
				return float2(final_h, 0);
            }
            ENDCG
        }
    }
}
