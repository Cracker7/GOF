Shader "Custom/OutlineURP"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth ("Outline Width", Range(0, 5)) = 0.03
        _MainTex ("Base Texture", 2D) = "white" {}
    }

    SubShader
    {
// Outline
Pass
{
    Name "Outline"
    Tags
    {
        "RenderType" = "Opaque"
        "LightMode" = "Outline"
    }
    Stencil
    {
        Ref 1
        Comp NotEqual
    }

    HLSLPROGRAM
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    #pragma vertex vert
    #pragma fragment frag
    
    #pragma multi_compile _OUTLINE_NML _OUTLINE_POS

    TEXTURE2D(_BaseMap);
    SAMPLER(sampler_BaseMap);
    TEXTURE2D(_BumpMap);
    SAMPLER(sampler_BumpMap);
    TEXTURE2D(_EmissionMask);
    
    CBUFFER_START(UnityPerMaterial)
        half    _Cutoff;
        float4 _BaseMap_ST;
        half4 _BaseColor;
        float4 _EmissionMask_ST;
        half4 _EmissionColor;
        // Outline
        float _OutlineWidth;
        half4 _OutlineColor;
    CBUFFER_END
    
    struct Attributes
    {
        float3 pos : POSITION;
        float4 tex_coord: TEXCOORD0;
        half3 normal: NORMAL;
        half4 tangent: TANGENT;
        UNITY_VERTEX_INPUT_INSTANCE_ID 
    };

    struct Varyings
    {
        float4 pos : SV_POSITION;
        float2 tex_coord: TEXCOORD0;
        UNITY_VERTEX_INPUT_INSTANCE_ID
        UNITY_VERTEX_OUTPUT_STEREO
    };

    Varyings vert(Attributes IN)
    {
        Varyings OUT;
        ZERO_INITIALIZE(Varyings, OUT);
        
        UNITY_SETUP_INSTANCE_ID(IN);
        UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
        
        float3 normalOS = 0;
    #ifdef _OUTLINE_NML
        normalOS = IN.normal;
    #elif _OUTLINE_POS
        normalOS = normalize(IN.pos.xyz); // For Hard Edge
    #endif
        VertexNormalInputs normalInput = GetVertexNormalInputs(normalOS, IN.tangent);
        
        float3 normal = 0;
        // inverse transpose View Matrix
        normal = mul(normalInput.normalWS, (float3x3)GetViewToWorldMatrix());
        float4 offset = TransformWViewToHClip(normal);
        
        // Outline Offset
        OUT.pos = TransformObjectToHClip(IN.pos);
        OUT.pos.xy += offset.xy * _OutlineWidth * 0.01;
        
        return OUT;
    }

    half4 frag(Varyings IN) : SV_Target
    {
        UNITY_SETUP_INSTANCE_ID(IN);
        UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(IN);

        half4 outColor = half4(0.0, 0.0, 0.0, 0.5);
        outColor.rgb = _OutlineColor.rgb; 
        return outColor;
    }
    ENDHLSL
}

    }
}