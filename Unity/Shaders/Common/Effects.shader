/***********************************************************************************************
 ***                                    通用特效                                             ***
 ***********************************************************************************************
 *属性:                                                                                        *
 *    _SrcBlend，_DstBlend：混合方式.                                                          *
 *    _CullMode：裁剪方式                                                                      *
 *    _ZTest：深度测试比较方式                                                                 *
 *    _ZWrite：是否开启深度写入                                                                *
 *                                                                                             *
 *    _MainTex：主纹理                                                                         *
 *    _MainUVSpeedX：主纹理X方向流动速度                                                       *
 *    MainUVSpeedY：主纹理Y方向流动速度                                                        *
 *                                                                                             *
 *    _MaskEnable：是否启用遮罩                                                                *
 *    _MaskTex：遮罩纹理                                                                       *
 *    _MaskUVSpeedX：遮罩纹理X方向流动速度                                                     *
 *    _MaskUVSpeedY：遮罩纹理Y方向流动速度                                                     *
 *                                                                                             *              
 *    _DistorEnable：是否启用扭曲                                                              *
 *    _DistorTex:扭曲纹理                                                                      *
 *    _Distorted：扭曲程度                                                                     *
 *    _DistorUVSpeedX：扭曲纹理X方向流动速度                                                   *
 *    _DistorUVSpeedY：扭曲纹理Y方向流动速度                                                   *
 *---------------------------------------------------------------------------------------------*
 * 效果:                                                                                       *
 *   通用的特效使用的shader，支持各类配置及遮罩、扭曲效果                                      *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
Shader "JJQ_Shader/Effects"
{
    Properties
    {
        [Header(RendingMode)]
        //使用枚举
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend",int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend",int) = 0
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest",int) = 0
        [Enum(Off,0,On,1)]_ZWrite("ZWrite",int) = 0

        [Header(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _MainUVSpeedX("MainUVSpeedX",Range(-4,4)) = 0
        _MainUVSpeedY("MainUVSpeedY",Range(-4,4)) = 0

        [Header(Mask)]//遮罩
        [Toggle]_MaskEnable("MaskEnable",int) = 0
        _MaskTex("MaskTex",2D) = "white" {}
        _MaskUVSpeedX("MaskUVSpeedX",Range(-4,4)) = 0
        _MaskUVSpeedY("MaskUVSpeedY",Range(-4,4)) = 0

        [Header(Distor)]//扭曲
        [Toggle]_DistorEnable("DistorEnable",int) = 0
        _DistorTex("DistorTex",2D) = "white" {}
        _Distorted("Distorted",Range(0,1)) = 0
        _DistorUVSpeedX("DistorUVSpeedX",Range(-4,4)) = 0
        _DistorUVSpeedY("DistorUVSpeedY",Range(-4,4)) = 0

    }
    SubShader
    {        
        Tags{"Queue" = "Transparent"}
        Blend [_SrcBlend] [_DstBlend]
        Cull [_CullMode]
        ZWrite [_ZWrite]
        ZTest [_ZTest]
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _MASKENABLE_ON
            #pragma shader_feature _DISTORENABLE_ON
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;                
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float2 distorUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;float4 _MainTex_ST;
            sampler2D _MaskTex;float4 _MaskTex_ST;
            sampler2D _DistorTex;float4 _DistorTex_ST;
            float _MainUVSpeedX,_MainUVSpeedY;
            float _MaskUVSpeedX,_MaskUVSpeedY;
            float _DistorUVSpeedX,_DistorUVSpeedY,_Distorted;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex) + float2(_MainUVSpeedX,_MainUVSpeedY) * _Time.y;
                #if _MASKENABLE_ON
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex) + float2(_MaskUVSpeedX,_MaskUVSpeedY) * _Time.y;
                #endif

                #if _DISTORENABLE_ON
                o.distorUV = TRANSFORM_TEX(v.uv, _DistorTex) + float2(_DistorUVSpeedX,_DistorUVSpeedY) * _Time.y;
                #endif

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                float2 distoredUV = i.uv.xy;
                #if _DISTORENABLE_ON
                fixed4 distorTex = tex2D(_DistorTex,i.distorUV);
                distoredUV = lerp(i.uv.xy,distorTex,_Distorted);
                #endif

                fixed4 col = tex2D(_MainTex, distoredUV);

                #if _MASKENABLE_ON
                fixed4 maskTex = tex2D(_MaskTex,i.uv.zw);
                col *= maskTex;
                #endif
                
                return col;
            }
            ENDCG
        }
    }
}
