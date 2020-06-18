/***********************************************************************************************
 ***                                    笑脸                                           		 ***
 ***********************************************************************************************
 *---------------------------------------------------------------------------------------------*
 * 思路:                                                                                       *
 *   使用画圆的方式拼接处笑脸                                                                  *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
Shader "ShaderToy/SmileFace"
{
    Properties
    {
        _MainTex("MainTex",2D) = "white" {}
        
    }
    SubShader
    {        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag            

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {                
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;                
            };

            sampler2D _MainTex;float4 _MainTex_ST;
            float _Radius;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            //画圆
            float Circle(float2 uv,float2 center,float rad,float blur)
            {
                //计算当前点相对于center的距离
                float dis = length(uv - center);
                // float c = 1 - smoothstep(rad-blur,rad,dis);
                //此处使用反区间，dis小于rad-blur则返回1
                float c = smoothstep(rad,rad-blur,dis);
                return c;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                col = Circle(i.uv,0.5,0.3,0.02) * fixed4(1,1,0,1);
                col -= Circle(i.uv,float2(0.35,0.6),0.05,0.01);
                col -= Circle(i.uv,float2(0.65,0.6),0.05,0.01);
                float mouse = Circle(i.uv,float2(0.5,0.5),0.25,0.02);
                mouse -= Circle(i.uv,float2(0.5,0.6),0.25,0.02);
                col *= 1 - mouse;
                return col;    
            }
            ENDCG
        }
    }
}
