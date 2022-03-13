Shader "Gwy/SkyboxProc"
{
    Properties
    {
        _SunColor ("Sun Color", Color) = (1, 1, 1, 1)
        _SunRadius ("Sun Radius", float) = 0
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
            #pragma shader_feature FUZZY
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD0;
            };

            struct v2f
            {
                float3 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _Stars, _BaseNoise, _Distort, _SecNoise;

            float _SunRadius, _MoonRadius, _MoonOffset, _OffsetHorizon;
            float4 _SunColor, _MoonColor;
            float4 _DayTopColor, _DayBottomColor, _NightBottomColor, _NightTopColor;
            float4 _HorizonColorDay, _HorizonColorNight, _SunSet;
            float _StarsCutoff, _StarsSpeed, _HorizonIntensity;
            float _BaseNoiseScale, _DistortScale, _SecNoiseScale, _Distortion;
            float _Speed, _CloudCutoff, _Fuzziness, _FuzzinessUnder, _Brightness;
            float4 _CloudColorDayEdge, _CloudColorDayMain, _CloudColorDayUnder;
            float4 _CloudColorNightEdge, _CloudColorNightMain, _CloudColorNightUnder, _StarsSkyColor;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float3 getViewDir(float3 worldPos)
            {
                float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
                return viewDirection;
            }

            float remap(float inValue, float2 inMinMax, float2 outMinMax)
            {
                float result = outMinMax.x + (inValue - inMinMax.x) * (outMinMax.y - outMinMax.y) / (inMinMax.y - inMinMax.x);
                return result;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                //太阳的位置
                float3 sunDir = -1 * _WorldSpaceLightPos0;
                float sunRadiusMin = 0;
                float sunRadiusMax = 0.1;

                sunDir = normalize(sunDir);
                float3 viewDir = normalize(getViewDir(i.worldPos));
                //太阳和视角方向夹角
                float sunAngle = dot(sunDir, viewDir);
                sunAngle = clamp(sunAngle, 0, 1);

                sunRadiusMin = min(sunRadiusMin, sunRadiusMax);
                sunRadiusMax = max(sunRadiusMin, sunRadiusMax);

                sunRadiusMin *= sunRadiusMin;
                sunRadiusMax *= sunRadiusMax;

                sunRadiusMin = 1 - sunRadiusMin;
                sunRadiusMax = 1 - sunRadiusMax;

                float sunOut = remap(1, float2(-1, 1), float2(0.5, 1));
                //-1
                //sunOut = clamp(sunOut, 0, 1);
                //sunOut = pow(sunOut, 5);
                float3 sunColor = _SunColor.rgb * sunOut * 2;

                float3 combined = sunColor;
                return float4(sunOut, 0, 0, 1);
            }
            ENDCG
        }
    }
}