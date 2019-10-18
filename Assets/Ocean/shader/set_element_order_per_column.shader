Shader "Hidden/set_element_order_per_column"
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

			float2 frag(v2f i) : SV_Target
			{
				// 轉成整數索引
				uint2 index = uv_to_uint(i.uv);
				
				// bit inverse
				index.y = bit_inverse(index.y);

				//轉回float索引
				float2 target_uv = index_to_uv(index);//float2 target_uv = (index * 1.) / h;

				float2 complex = tex2D(_MainTex, target_uv).rg;
				return complex;
            }
            ENDCG
        }
    }
}
