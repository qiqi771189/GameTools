/***********************************************************************************************
 ***                                    从中间展开的图片                                     ***
 ***********************************************************************************************
 *属性:                                                                                        *
 *    _MainTex：主纹理.                                                                        *
 *    _CircleDiffuseSpeed：圆展开速度                                                          *
 *    _WaveLength：波纹的长度                                                                  *
 *    _WaveHeigh：波纹的高度（体现不太出来）                                                   *
 *    _DiffuseSpeed：波纹的速度                                                                *
 *    _WaveIntensity：波纹强度                                                                 *
 *---------------------------------------------------------------------------------------------*
 * 效果:                                                                                       *
 *   从中间展开的带有波纹的图片（仿荒野乱斗地图展开效果，但荒野乱斗明显不是这种方案）          *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
Shader "ShaderToy/DiffuseFromCenter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Header(Circle)]
        _CircleDiffuseSpeed("CircleDiffuseSpeed(Smaller Faster)",float) = 4

        [Header(Wave)]
        _WaveLength("WaveLength",float) = 60
        _WaveHeigh("_WaveHeigh",float) = 0.1
        _DiffuseSpeed("DiffuseSpeed(Smaller Faster)",float) = 1.6
        _WaveIntensity("WaveIntensity",Range(0,1)) = 0.1        
    }
    SubShader
    {        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _WARPMODE_REPEAT _WARPMODE_CLAMP
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _CircleDiffuseSpeed,_WaveHeigh,_WaveLength,_DiffuseSpeed,_WaveIntensity;        

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //waromode
                // #if _WARPMODE_REPEAT
                //     return 1;
                // #elif _WARPMODE_CLAMP
                //     return 0.7;
                // #endif

                float2 dv = normalize(i.uv - float2(0.5,0.5));
                float dis = length(i.uv - 0.5);
                float offsetX = sin(dis * _WaveLength) * _WaveHeigh;
                float TimeSection = frac(dis - _Time.y/_CircleDiffuseSpeed);
                float WaveTimeSection = frac(dis - _Time.y/_DiffuseSpeed);
                //当前波纹离中心的距离
                float curWave = 1-WaveTimeSection;
                //           波纹效果      打断波纹的连续                               波纹区间
                i.uv += offsetX * dv * clamp(curWave-dis+_WaveIntensity,0,1) * clamp((curWave-dis)*(dis-curWave+0.3)*100,0,1);

                fixed4 col = tex2D(_MainTex, i.uv.xy);
                clip(TimeSection - dis);
                return col;
            }
            ENDCG
        }
    }
}
