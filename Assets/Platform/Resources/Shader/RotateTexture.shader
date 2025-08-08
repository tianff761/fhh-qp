// Shader created with Shader Forge v1.38 
// Shader Forge (c) Freya Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:1,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:0,bsrc:3,bdst:7,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:False,atwp:True,stva:1,stmr:255,stmw:255,stcp:2,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:9361,x:33687,y:32422,varname:node_9361,prsc:2|custl-441-RGB,alpha-441-A;n:type:ShaderForge.SFN_TexCoord,id:612,x:32574,y:32210,varname:node_612,prsc:2,uv:0,uaff:False;n:type:ShaderForge.SFN_Tex2d,id:441,x:33490,y:32494,ptovrint:False,ptlb:MainTex,ptin:_MainTex,varname:node_441,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:True,tagnsco:False,tagnrm:False,tex:a45ed36459af84e41941ff7d8a8b24f3,ntxv:2,isnm:False|UVIN-5680-UVOUT;n:type:ShaderForge.SFN_Slider,id:6014,x:32655,y:32538,ptovrint:False,ptlb:angle,ptin:_angle,varname:node_6014,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:90,max:360;n:type:ShaderForge.SFN_Rotator,id:5680,x:33318,y:32478,varname:node_5680,prsc:2|UVIN-9458-OUT,ANG-6275-OUT;n:type:ShaderForge.SFN_RemapRange,id:586,x:32973,y:32534,varname:node_586,prsc:2,frmn:0,frmx:360,tomn:0,tomx:2|IN-6014-OUT;n:type:ShaderForge.SFN_Pi,id:1212,x:33000,y:32694,varname:node_1212,prsc:2;n:type:ShaderForge.SFN_Multiply,id:6275,x:33134,y:32596,varname:node_6275,prsc:2|A-586-OUT,B-1212-OUT;n:type:ShaderForge.SFN_RemapRange,id:8434,x:32825,y:32116,varname:node_8434,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-612-U;n:type:ShaderForge.SFN_SwitchProperty,id:4931,x:33087,y:32156,ptovrint:False,ptlb:horizontal,ptin:_horizontal,varname:node_4931,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:True|A-612-U,B-8434-OUT;n:type:ShaderForge.SFN_RemapRange,id:8384,x:32821,y:32276,varname:node_8384,prsc:2,frmn:0,frmx:1,tomn:1,tomx:0|IN-612-V;n:type:ShaderForge.SFN_SwitchProperty,id:4437,x:33083,y:32316,ptovrint:False,ptlb:vertical,ptin:_vertical,varname:_horizontal_copy,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,on:False|A-612-V,B-8384-OUT;n:type:ShaderForge.SFN_Append,id:9458,x:33321,y:32214,varname:node_9458,prsc:2|A-4931-OUT,B-4437-OUT;proporder:441-6014-4931-4437;pass:END;sub:END;*/

Shader "SF/RotateTexture" {
    Properties {
        [PerRendererData]_MainTex ("MainTex", 2D) = "black" {}
        _angle ("angle", Range(0, 360)) = 90
        [MaterialToggle] _horizontal ("horizontal", Float ) = 1
        [MaterialToggle] _vertical ("vertical", Float ) = 0
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
        _Stencil ("Stencil ID", Float) = 0
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilComp ("Stencil Comparison", Float) = 8
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilOpFail ("Stencil Fail Operation", Float) = 0
        _StencilOpZFail ("Stencil Z-Fail Operation", Float) = 0
		
        _ColorMask ("Color Mask", Float) = 15
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Stencil {
                Ref [_Stencil]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilOp]
                Fail [_StencilOpFail]
                ZFail [_StencilOpZFail]
            }
            ColorMask [_ColorMask]
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma target 3.0
            uniform sampler2D _MainTex; uniform float4 _MainTex_ST;
            uniform float _angle;
            uniform fixed _horizontal;
            uniform fixed _vertical;
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0 = v.texcoord0;
                o.pos = UnityObjectToClipPos( v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
////// Lighting:
                float node_5680_ang = ((_angle*0.005555556+0.0)*3.141592654);
                float node_5680_spd = 1.0;
                float node_5680_cos = cos(node_5680_spd*node_5680_ang);
                float node_5680_sin = sin(node_5680_spd*node_5680_ang);
                float2 node_5680_piv = float2(0.5,0.5);
                float2 node_5680 = (mul(float2(lerp( i.uv0.r, (i.uv0.r*-1.0+1.0), _horizontal ),lerp( i.uv0.g, (i.uv0.g*-1.0+1.0), _vertical ))-node_5680_piv,float2x2( node_5680_cos, -node_5680_sin, node_5680_sin, node_5680_cos))+node_5680_piv);
                float4 _MainTex_var = tex2D(_MainTex,TRANSFORM_TEX(node_5680, _MainTex));
                float3 finalColor = _MainTex_var.rgb;
                return fixed4(finalColor,_MainTex_var.a);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
