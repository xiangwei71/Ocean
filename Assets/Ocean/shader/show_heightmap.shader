Shader "Unlit/show_heightmap"
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

				//因為block之間會重疊	
				//比如說2個block分別是 0~63 ,63~126
				//uint2 block = FFT_h / 8;
				//uint2 height_map_index= uv * (block-1) + _block_offset * (block-1);
				//float2 height_map_uv = index_to_uv(height_map_index);

				//我組了1個超大的512x512的grid
				uint2 height_map_index = uv * (FFT_h - 1);
				float2 height_map_uv = index_to_uv(height_map_index);

				// read height map
				float h = tex2Dlod(_MainTex, float4(height_map_uv, 0, 0)).r;
				//detail_factor變大時，亮度會變底，這個要調高;
				v.vertex.y = 30* pow(detail_factor,2) *h;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.height_map_uv = height_map_uv;
                return o;
            }

			float4 frag(v2f i) : SV_Target
			{
				//return float4(i.height_map_uv.x,0,0,1);
				float h = tex2D(_MainTex, i.height_map_uv).r;
				//detail_factor變大時，亮度會變弱，這個要調高;
				h *= 10*detail_factor;
				return  float4(h,h,h,1.);
                //return float4(0.25,0.5,0.25,1);
            }
            ENDCG
        }
    }
}
