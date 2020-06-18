/***********************************************************************************************
 ***                                    不受光角色                                           ***
 ***********************************************************************************************
 *属性:                                                                                        *
 *    _MainTex：主纹理.                                                                        *
 *    _Color：主纹理颜色                                                                       *
 *    _DissolveEnabled：是否开启溶解                                                           *
 *    _DissolveTex：溶解纹理                                                                   *
 *    _RampTex：溶解渐变色纹理                                                                 *
 *    _Clip：当前溶解程度                                                                      *
 *    _Shadow：阴影                                                                            *
 *---------------------------------------------------------------------------------------------*
 * 效果:                                                                                       *
 *   不受光照影响的角色，及溶解效果（会影响阴影）                                              *
 * - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - */
Shader "JJQ_Shader/CharacterUnit"
{
    Properties
    {
        [Header Base]
        [NoScaleOffset]_MainTex ("MainTex", 2D) = "white" {}
        _Color("Color",Color) = (0,0,0,0)

        [Space(10)]
        [Header(Dissolve)]
        [Toggle]_DissolveEnabled("DissolveEnabled",Int) = 0
        _DissolveTex("DissolveTex",2D) = "white"{}
        [NoScaleOffset]_RampTex("RampTex(RGB)",2D) = "white"{}
        _Clip("Clip",Range(0,1)) = 0

        [Header(Shadow)]
        _Shadow("Offset(x,z) Height(y)",Vector) = (0.2,0,0.4,0)

    }
    SubShader
    {    
        Tags{"Queue" = "Geometry"}
        LOD 600
        Blend Off
        Offset 0,0        
        Pass
        {
            Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            #pragma multi_compile_fwdbase
            #pragma multi_compile DIRECTIONAL SHADOWS_SCREEN
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            sampler2D _MainTex;
            fixed4 _Color;

            sampler2D _DissolveTex;float4 _DissolveTex_ST;
            sampler _RampTex;
            fixed _Clip;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                UNITY_SHADOW_COORDS(2)
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                fixed4 c;
                fixed4 Tex = tex2D(_MainTex, i.uv.xy);
                c = Tex + _Color;

                #if _DISSOLVEENABLED_ON
                    fixed4 DissolveTex = tex2D(_DissolveTex, i.uv.zw);
                    clip(DissolveTex.r - _Clip);
                    fixed dissolveValue = saturate((DissolveTex.r - _Clip) / 0.1);
                    fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                    c += rampTex;
                #endif                
                return c *= atten;
            }
            ENDCG
        }

        //产生阴影
        // Pass
        // {
        //     Tags {"LightMode" = "ShadowCaster"}
        //     CGPROGRAM
        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma multi_compile_shadowCaster
        //     #pragma multi_compile _ _DISSOLVEENABLED_ON
        //     #include "UnityCG.cginc"

        //     struct appdata
        //     {
        //         float4 vertex:POSITION;
        //         half3 normal:NORMAL;
        //         fixed4 uv:TEXCOORD0;
        //     };

        //     struct v2f
        //     {
        //         V2F_SHADOW_CASTER;
        //         fixed4 uv:TEXCOORD0;
        //     };

        //     sampler2D _DissolveTex;float4 _DissolveTex_ST;
        //     fixed _Clip;

        //     v2f vert(appdata v)
        //     {
        //         v2f o;
        //         TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
        //         o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
        //         return o;
        //     }

        //     fixed4 frag(v2f i):SV_TARGET
        //     {
        //         #if _DISSOLVEENABLED_ON
        //             fixed4 DissolveTex = tex2D(_DissolveTex, i.uv.zw);
        //             clip(DissolveTex.r - _Clip);
        //             // fixed dissolveValue = saturate((DissolveTex.r - _Clip) / 0.1);
        //             // fixed4 rampTex = tex1D(_RampTex,dissolveValue);
        //             // c += rampTex;
        //         #endif
        //         SHADOW_CASTER_FRAGMENT(i);
        //     }
        
        //     ENDCG
        // }
    }

    SubShader
    {
        LOD 400
        Pass
        {
            // Tags{"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _DISSOLVEENABLED_ON
            // #pragma multi_compile_fwdbase
            // #pragma multi_compile DIRECTIONAL SHADOWS_SCREEN
            #include "UnityCG.cginc"
            // #include "AutoLight.cginc"
            sampler2D _MainTex;
            fixed4 _Color;

            sampler2D _DissolveTex;float4 _DissolveTex_ST;
            sampler _RampTex;
            fixed _Clip;

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                // float4 worldPos : TEXCOORD1;
                // UNITY_SHADOW_COORDS(2)
            };

            v2f vert (appdata v)
            {
                v2f o;                
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = v.uv.xy;
                o.uv.zw = TRANSFORM_TEX(v.uv,_DissolveTex);
                // o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                // TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                fixed4 c;
                fixed4 Tex = tex2D(_MainTex, i.uv.xy);
                c = Tex + _Color;

                #if _DISSOLVEENABLED_ON
                    fixed4 DissolveTex = tex2D(_DissolveTex, i.uv.zw);
                    clip(DissolveTex.r - _Clip);
                    fixed dissolveValue = saturate((DissolveTex.r - _Clip) / 0.1);
                    fixed4 rampTex = tex1D(_RampTex,dissolveValue);
                    c += rampTex;
                #endif                
                // return c *= atten;
                return c;
            }
            ENDCG
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Stencil
            {
                Ref 100
                Comp NotEqual
                Pass Replace                
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile _ _DISSOLVEENABLED_ON

            sampler2D _DissolveTex;float4 _DissolveTex_ST;            
            fixed _Clip; 
            float4 _Shadow;

            struct appdata
            {
                float4 vertex : POSITION;
                fixed2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv,_DissolveTex);                
                float4 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float worldPosYTemp = worldPos.y;
                worldPos.y = _Shadow.y;
                // worldPos.xz += fixed2(1,2);
                worldPos.xz += _Shadow.xz * (worldPosYTemp - _Shadow.y);
                o.pos = mul(UNITY_MATRIX_VP,worldPos);//UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c = 0;
                c.a = _Shadow.w;
                #if _DISSOLVEENABLED_ON
                    fixed4 DissolveTex = tex2D(_DissolveTex, i.uv);
                    clip(DissolveTex.r - _Clip);
                    fixed dissolveValue = saturate((DissolveTex.r - _Clip) / 0.1);                    
                #endif
                return c;
            }

            ENDCG            
        }
    }

    SubShader
    {
        LOD 200
        Pass
        {

        }
    }

    
}