Shader "Gwy/TestSkyBoxUV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" { }
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            #define PI 3.141592653589793

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            //重构天空盒uv
            //x-》0 - 1
            //y-> -1 - 1
            float2 parseWorldPos2SkyUV(float3 worldPos)
            {
                worldPos = normalize(worldPos);
                float2 newUV;
                newUV.y = asin(worldPos.y) / (PI * 0.5);
                newUV.x = atan2(worldPos.x, worldPos.z) / (PI * 2) + 0.5;
                return newUV;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 worldPos = i.worldPos;
                worldPos = normalize(worldPos);

                float4 color = 0;
                color.r= abs(worldPos.x/1);
                //color.g= abs(worldPos.y/1);
                //color.b= abs(worldPos.z/1);
                return color;

                // sample the texture
                //fixed4 col = tex2D(_MainTex, newUV);
                //// apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                //return col;
            }
            ENDCG
        }
    }
}