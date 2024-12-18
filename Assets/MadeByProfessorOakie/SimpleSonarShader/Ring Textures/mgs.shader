Shader "URP/OutlineShader"
{
    Properties
    {
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1, 1, 1, 1) // �ƿ����� ����
        _OutlineWidth("Outline Width", Float) = 0.05 // �ƿ����� �β�
    }

    SubShader
    {
        Tags { "RenderPipeline" = "UniversalRenderPipeline" "RenderType" = "Opaque" }
        Pass
        {
            Name "OutlinePass"
            Tags { "LightMode" = "UniversalForward" }
            Cull Front // �ո� ����
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
                float4 positionHCS : SV_POSITION; // Ŭ�� ���� ��ǥ
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float3 normalWS = TransformObjectToWorldNormal(IN.normalOS); // ����� ���� ��ǥ�� ��ȯ
                float3 offset = normalWS * _OutlineWidth; // �ƿ����� �β� ����
                float4 positionWS = TransformObjectToWorld(IN.positionOS) + float4(offset, 0.0); // ���� ��ǥ �̵�
                OUT.positionHCS = TransformWorldToHClip(positionWS); // Ŭ�� �������� ��ȯ
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                return _OutlineColor; // �ƿ����� ���� ��ȯ
            }
            ENDHLSL
        }

        Pass
        {
            Name "MainPass"
            Tags { "LightMode" = "UniversalForward" }
            Cull Back // �ܰ����� �ߺ����� �ʵ��� �޸� ����
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
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS); // Ŭ�� ���� ��ǥ
                OUT.uv = IN.uv;
                return OUT;
            }

            float4 frag(Varyings IN) : SV_Target
            {
                return float4(0, 0, 0, 1); // ������ ��ü ������
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}

