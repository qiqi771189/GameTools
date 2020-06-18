/***********************************************************************************************
 ***                                    热扰动                                               ***
 ***********************************************************************************************
 *属性:                                                                                        *
 *    _DistortTex：扰动纹理.                                                                   *
 *    _Distort：X,Y表示扰动纹理X,Y方向的流动速度，Z表示扰动的强度                              *
 *---------------------------------------------------------------------------------------------*
 * 效果:                                                                                       *
 *   热扰动                                                                                    *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
Shader "JJQ_Shader/HeatDistort"
{
    Properties
    {
        _DistortTex ("DistortTex", 2D) = "white" {}
        // _Distored("Distored",Range(0,1)) = 0
        // _DistortUVSpeedX("DistortUVSpeedX",Range(-4,4)) = 0
        // _DistortUVSpeedY("DistortUVSpeedY",Range(-4,4)) = 0
        _Distort("SpeedX(X) SpeedX(Y) Distored(Z)",Vector)=(0,0,0,0)
    }
    SubShader
    {      
        Tags{"Queue" = "Transparent"} 
        Cull off
        GrabPass//抓取屏幕
        {"_GrabTex"} 
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            

            #include "UnityCG.cginc"            

            struct v2f
            {
                float2 uv : TEXCOORD0;                
            };

            sampler2D _GrabTex;
            sampler2D _DistortTex;float4 _DistortTex_ST;
            // fixed _Distored;
            // float _DistortUVSpeedX,_DistortUVSpeedY;
            float4 _Distort;

            v2f vert (
                float4 vertex : POSITION,
                float2 uv:TEXCOORD0,
                out float4 pos : SV_POSITION           
            )
            {
                v2f o;
                pos = UnityObjectToClipPos(vertex); 
                o.uv = TRANSFORM_TEX(uv,_DistortTex) + float2(_Distort.x,_Distort.y) * _Time.y;
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos : VPOS) : SV_Target
            {                
                fixed2 screenUV = screenPos.xy / _ScreenParams.xy;
                fixed4 DistortTex = tex2D(_DistortTex,i.uv);
                float2 uv = lerp(screenUV,DistortTex,_Distort.z);
                fixed4 grabTex = tex2D(_GrabTex,uv);
                return grabTex;
            }
            ENDCG
        }
    }
}
