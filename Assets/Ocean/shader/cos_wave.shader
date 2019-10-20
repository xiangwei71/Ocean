Shader "Hidden/cos_wave"
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
			#include "FFT/FFT_Utils.cginc"

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

			float remap(float x) {
				float y=(x + 1) / 2;
				return pow(y, 2);
			}

			float2 frag(v2f i) : SV_Target
			{
				float2 uv = i.uv;
				uv = sapmle_point_offset_and_scale(uv);
				uv = uv * 2 - 1; // to -1~1
				uv *= 3.14; // to -Pi~Pi
				float x = uv.x;
				float y = uv.y;
				float t = _Time.y;
				float f = 2;

				float h = 0;
				h += remap(cos(x + y + 200+t));
				h += 0.25 * remap(cos(4 * (x + y) + t));
				h += 0.5*remap(cos(4*x + t));
				h += 2 * remap(cos(x + t));
				

				return float2(h,0);
            }
            ENDCG
        }
    }
}
