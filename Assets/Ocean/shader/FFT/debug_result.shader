﻿Shader "Unlit/debug_result"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

			#include "../PhillipsSpectrum/PhillipsSpectrum.cginc"
            #include "UnityCG.cginc"

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
				// for height map
				float h = tex2D(_MainTex, i.uv).r;
				h = 30 * pow(detail_factor, 2) * h;
				h = (h + 30) / 60;// for detail_factor==10
				return float4(h, h, h, 1);

                // for  FFT testing
				float4 col = tex2D(_MainTex, i.uv);
				return float4(col.r, col.g, 0, 1);
                
				// peek 共軛複數
				//return float4(col.r,-col.g,0,1);
            }
            ENDCG
        }
    }
}
