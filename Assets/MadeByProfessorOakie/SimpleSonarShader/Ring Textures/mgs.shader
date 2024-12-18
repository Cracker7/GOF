Shader "URP/OutlineShader"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1) // 아웃라인 색상
        _OutlineWidth("Outline Width", Float) = 0.05 // 아웃라인 두께
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
        Pass
        {
            Name "OutlinePass"
            Tags { "LightMode" = "UniversalForward" }
            Cull Front // 앞면 제거
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            float4 _OutlineColor;
            float _OutlineWidth;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION; // 클립 공간 좌표
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS); // 노멀을 월드 좌표로 변환
                float3 offset = normalWS * _OutlineWidth; // 아웃라인 두께 적용
                float4 positionWS = TransformObjectToWorld(IN.positionOS) + float4(offset, 0.0); // 월드 좌표 이동
                OUT.positionHCS = TransformWorldToHClip(positionWS); // 클립 공간으로 변환
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor; // 아웃라인 색상 반환
            }
            ENDHLSL
        }

        Pass
        {
            Name "MainPass"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back // 외곽선과 중복되지 않도록 뒷면 제거
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            sampler2D _MainTex;

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 positionHCS : SV_POSITION;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS); // 클립 공간 좌표
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                return float4(0, 0, 0, 1); // 검은색 본체 렌더링
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}

