Shader "Gwy/SkyboxProc"
{
    Properties
    {
        [Header(Stars Settings)]
        _Stars ("Stars Texture", 2D) = "black" { }
        _StarsCutoff ("Stars Cutoff", Range(0, 1)) = 0.08
        _StarsSpeed ("Stars Move Speed", Range(0, 1)) = 0.3
        _StarsSkyColor ("Stars Sky Color", Color) = (0.0, 0.2, 0.1, 1)

        [Header(Horizon Settings)]
        _OffsetHorizon ("Horizon Offset", Range(-1, 1)) = 0
        //地平线强度
        _HorizonIntensity ("Horizon Intensity", Range(0, 10)) = 3.3
        //日落颜色
        _SunSet ("Sunset/Rise Color", Color) = (1, 0.8, 1, 1)
        _HorizonColorDay ("Day Horizon Color", Color) = (0, 0.8, 1, 1)
        _HorizonColorNight ("Night Horizon Color", Color) = (0, 0.8, 1, 1)

        [Header(Sun Settings)]
        _SunColor ("Sun Color", Color) = (1, 1, 1, 1)
        _SunRadius ("Sun Radius", Range(0, 2)) = 0.1

        [Header(Moon Settings)]
        _MoonColor ("Moon Color", Color) = (1, 1, 1, 1)
        _MoonRadius ("Moon Radius", Range(0, 2)) = 0.15
        _MoonOffset ("Moon Crescent", Range(-1, 1)) = -0.1

        [Header(Day Sky Settings)]
        _DayTopColor ("Day Sky Color Top", Color) = (0.4, 1, 1, 1)
        _DayBottomColor ("Day Sky Color Bottom", Color) = (0, 0.8, 1, 1)

        [Header(Main Cloud Settings)]
        _BaseNoise ("Base Noise", 2D) = "black" { }
        _Distort ("Distort", 2D) = "black" { }
        _SecNoise ("Secondary Noise", 2D) = "black" { }
        _BaseNoiseScale ("Base Noise Scale", Range(0, 1)) = 0.2
        _DistortScale ("Distort Noise Scale", Range(0, 1)) = 0.06
        _SecNoiseScale ("Secondary Noise Scale", Range(0, 1)) = 0.05
        _Distortion ("Extra Distortion", Range(0, 1)) = 0.1
        _Speed ("Movement Speed", Range(0, 10)) = 1.4
        _CloudCutoff ("Cloud Cutoff", Range(0, 1)) = 0.3
        _Fuzziness ("Cloud Fuzziness", Range(0, 5)) = 0.04
        _FuzzinessUnder ("Cloud Fuzziness Under", Range(0, 1)) = 0.01
        [Toggle(FUZZY)] _FUZZY ("Extra Fuzzy clouds", Float) = 1

        [Header(Day Clouds Settings)]
        _CloudColorDayEdge ("Clouds Edge Day", Color) = (1, 1, 1, 1)
        _CloudColorDayMain ("Clouds Main Day", Color) = (0.8, 0.9, 0.8, 1)
        _CloudColorDayUnder ("Clouds Under Day", Color) = (0.6, 0.7, 0.6, 1)
        _Brightness ("Cloud Brightness", Range(1, 10)) = 2.5
        [Header(Night Sky Settings)]
        _NightTopColor ("Night Sky Color Top", Color) = (0, 0, 0, 1)
        _NightBottomColor ("Night Sky Color Bottom", Color) = (0, 0, 0.2, 1)

        [Header(Night Clouds Settings)]
        _CloudColorNightEdge ("Clouds Edge Night", Color) = (0, 1, 1, 1)
        _CloudColorNightMain ("Clouds Main Night", Color) = (0, 0.2, 0.8, 1)
        _CloudColorNightUnder ("Clouds Under Night", Color) = (0, 0.2, 0.6, 1)
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

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = 0;
                float y = i.uv.z;
                if (y > 0)
                {
                    col = float4(y / 1, 0, 0, 1);
                }
                else
                {
                    col = float4(0, abs(y / 1), 0, 1);
                }
                //return col;
                // sun 默认_WorldSpaceLightPos0为太阳坐标
                float3 lightPos = normalize(_WorldSpaceLightPos0 + float3(0, 0, 0));
                float sun = distance(i.uv.xyz, lightPos);
                float sunRamp = 0.05;
                float sunDisc = 1 - (sun / _SunRadius);
                sunDisc = saturate(sunDisc * 50);

                float3 sunColor = sunDisc * float3(1, 0, 0);

                float3 combined = sunColor;
                return float4(sunDisc, 0, 0, 1);
            }
            ENDCG
        }
    }
}