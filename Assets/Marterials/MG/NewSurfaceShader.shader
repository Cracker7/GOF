Shader "mg"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {} 
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1) // 흰색 외곽선
        _OutlineWidth ("Outline Width", Float) = 0.05 //인스펙터 조정
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        // 패스 1: 외곽선 렌더링
        Pass
        {
            Name "Outline"
            Tags { "LightMode" = "Always" }
            Cull Front // 앞면 제거, 뒷면만 렌더링
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            float4 _OutlineColor;
            float _OutlineWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float3 norm = normalize(v.normal); // 노멀 벡터를 정규화
                v.vertex.xyz += norm * _OutlineWidth; // 아웃라인 외각 위치
                o.pos = UnityObjectToClipPos(v.vertex); // 공간의 정보
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return _OutlineColor; // 외각선 색
            }
            ENDCG
        }

        // 패스 2: 물체 렌더링
        Pass
        {
            Name "MainObject"
            Tags { "LightMode" = "ForwardBase" }
            Cull Back //외각선 컬링
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return float4(0, 0, 0, 1); //검은색에 알파 값 1
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
