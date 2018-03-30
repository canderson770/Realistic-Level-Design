// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


Shader "Cody/BestSnow" 
{
    Properties 
    {
    	_Color ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainBump ("Normal Map", 2D) = "bump" {}
        _SnowColor ("Snow color", Color) = (1, 1, 1, 1)
        _LayerTex ("Snow (RGB)", 2D) = "white" {}
        _LayerBump ("Snow Normal Map", 2D) ="bump" {}
        _LayerStrength ("Snow Amount", Range(0, 1)) = 0
        _LayerDirection ("Snow Direction", Vector) = (0, 1, 0)
//        _LayerDepth ("Layer Depth", Range(0, 0.005)) = 0.0005
		_MinHeight ("Min Height", float) = 0
		_MaxHeight ("Max Height", float) = 0

    }
   
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
       
        CGPROGRAM
        #pragma target 3.0
        #pragma surface surf Lambert vertex:vert

        half4 _Color;
        half4 _SnowColor;
        sampler2D _MainTex;
        sampler2D _MainBump;
        sampler2D _LayerTex;
        sampler2D _LayerBump;
        float _LayerStrength;
        float3 _LayerDirection;
        float _LayerDepth;
        float _MinHeight;
        float _MaxHeight;
 
        struct Input 
        {
            float2 uv_MainTex;
            float2 uv_MainBump;
            float2 uv_LayerTex;
            float2 uv_LayerBump;
            float3 worldNormal;
            INTERNAL_DATA
        };
       
        void vert (inout appdata_full v)
         {
            // Convert the normal to world coordinates/world space
            float3 sn = mul((float3x3)unity_WorldToObject, _LayerDirection);
           
            if (dot(v.normal, sn.xyz) >= lerp(1, -1, (_LayerStrength * 2) / 3))
            {
                v.vertex.xyz += (sn.xyz + v.normal) * _LayerDepth * _LayerStrength;
            }
        }
 
        void surf (Input IN, inout SurfaceOutput o)
         {
   
            // Diffuse color of pixel
            half4 mainDiffuse = tex2D(_MainTex, IN.uv_MainTex);
            half4 layerDiffuse = tex2D(_LayerTex, IN.uv_LayerTex);
           
            // Normal vector of pixel
            o.Normal = UnpackNormal(tex2D(_MainBump, IN.uv_MainBump));
            half3 layerNormal = half3(0, 0, 0);
           
            // Snow mask
            half sm = dot(WorldNormalVector(IN, o.Normal), _LayerDirection);
            sm = pow(0.5 * sm + 0.5, 2.0);

			if (IN.worldNormal.y < _MinHeight)
				 discard;

            if (sm >= lerp(1, 0, _LayerStrength))
            {
                o.Albedo = (layerDiffuse.rgb + 0.5 * mainDiffuse.rgb) * 0.75 * _SnowColor;
                layerNormal = UnpackNormal(tex2D(_LayerBump, IN.uv_LayerBump));
                o.Normal = normalize(o.Normal + layerNormal);
            }
            else
            {
                o.Albedo = mainDiffuse.rgb * _Color;
            }
       
            o.Alpha = mainDiffuse.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}