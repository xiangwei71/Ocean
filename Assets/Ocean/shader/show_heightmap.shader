﻿Shader "Unlit/show_heightmap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_block_offset("block_offset",Vector) = (0.,0.,0.,0.)
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
            // make fog work
            #pragma multi_compile_fog

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
				float2 height_map_uv:TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			float2 _block_offset;

            v2f vert (appdata v)
            {
				v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				//從blender匯進來的uv方向不太一樣，這裡動一下手腳
				float2 uv = o.uv;
				uv.x = 1 - uv.x;
				uv.y = 1 - uv.y;

				float2 block = float2(1. / 8, 1. / 8);
				float2 height_map_uv = uv * block + _block_offset * block;
				// read height map
				float h = tex2Dlod(_MainTex, float4(height_map_uv, 0, 0)).r;
				v.vertex.y = 1.2*h;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.height_map_uv = height_map_uv;
                return o;
            }

			float4 frag(v2f i) : SV_Target
			{
				//return float4(i.height_map_uv.x,0,0,1);
				return  float4(tex2D(_MainTex, i.height_map_uv).rrr,1.);
                //return float4(0.25,0.5,0.25,1);
            }
            ENDCG
        }
    }
}
