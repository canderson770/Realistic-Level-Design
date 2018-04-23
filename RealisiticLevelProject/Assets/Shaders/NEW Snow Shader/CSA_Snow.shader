Shader "CSA/Snow/Snow" 
{
    Properties 
    {
		_Tess("Tessellation", Range(1,64)) = 4

    	_Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Map", 2D) = "white" {}
        [Normal]_BumpMap ("Normal Map", 2D) = "bump" {}
      	_BumpScale("Normal Strength", float) = 1

        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)
        _SnowTex ("Snow Map", 2D) = "white" {}
        [Normal]_SnowBump ("Snow Normal", 2D) ="bump" {}
      	_SnowBumpScale("Snow Normal Strength", float) = 1

        _SnowAmount ("Snow Amount", Range(-0.5, 1)) = 0
        _SnowDirection ("Snow Direction", Vector) = (0, 1, 0)
        _SnowDepth("Snow Depth", Range(0, 1)) = 0

    	_PaintMap("Snow Footprints", 2D) = "white" {} // texture to paint on
        _SnowPrintsColor ("Snow Footprints Color", Color) = (1, 1, 1, 1)


      	[Toggle]_MatchTiling("Match Tiling", float) = 0
      	[Toggle]_SnowMatchTiling("Snow Match Tiling", float) = 0

        [Enum(UnityEngine.Rendering.CullMode)]_CullMode ("Cull Mode", Range(0,2)) = 2
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest ("ZTest", Range(0,6)) = 2
    }
   
    SubShader 
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
       	Cull [_CullMode]
        ZTest [_ZTest]

        CGPROGRAM
	        #pragma target 5.0
	        #pragma surface surf Lambert vertex:vert tessellate:tessDistance 
			#include "Tessellation.cginc"

	        uniform half4 _Color, _SnowColor, _SnowPrintsColor;
	        uniform sampler2D _MainTex, _BumpMap, _SnowTex, _SnowBump, _PaintMap;
	        uniform float _SnowAmount, _SnowDepth, _BumpScale, _SnowBumpScale, _MatchTiling, _SnowMatchTiling;
	        uniform float3 _SnowDirection;
	 
	        struct Input 
	        {
	            float2 uv_MainTex;
	            float2 uv_BumpMap;
	            float2 uv_SnowTex;
	            float2 uv_SnowBump;
	            float2 uv2_PaintMap;

	            float3 worldNormal;
	            float4 viewDir;
	            INTERNAL_DATA
	        };

	        struct appdata 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float2 texcoord2 : TEXCOORD2;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;

			};

			float _Tess;

			//this shader is based off of https://docs.unity3d.com/Manual/SL-SurfaceShaderTessellation.html
			float4 tessDistance(appdata v0, appdata v1, appdata v2) 
			{
				float minDist = 10.0;
				float maxDist = 25.0;
				return UnityDistanceBasedTess(v0.vertex, v1.vertex, v2.vertex, minDist, maxDist, _Tess);
			}

	        Input vert (inout appdata v)
	         {
	         	Input o;
	            // Convert the normal to world coordinates/world space
	            float3 sn = mul((float3x3)unity_WorldToObject, _SnowDirection);
	           
	            if (dot(v.normal, sn.xyz) >= lerp(1, -1, (_SnowAmount * 2) / 3))
	            {
	               	float4 heightM = tex2Dlod(_PaintMap, float4(v.texcoord.xy, 0, 0));
//
	                v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _SnowAmount;
//
					v.vertex.y += heightM.b * _SnowDepth;
	            }

				o.uv2_PaintMap = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;// lightmap uvs

				return o;
	        }
	 
	        void surf (Input IN, inout SurfaceOutput o)
	         {
	         	if(_MatchTiling == 0)
		   			IN.uv_BumpMap = IN.uv_MainTex;
		   		
				if(_SnowMatchTiling == 0)
	   				IN.uv_SnowBump = IN.uv_SnowTex;
	   			
	            // Diffuse color of pixel
	            half4 mainDiffuse = tex2D(_MainTex, IN.uv_MainTex);
	            half4 snowDiffuse = tex2D(_SnowTex, IN.uv_SnowTex);
	          	half4 snowprintsDiffuse = tex2D(_PaintMap, IN.uv2_PaintMap);

	            // Normal vector of pixel
	            o.Normal = UnpackScaleNormal(tex2D(_BumpMap, IN.uv_BumpMap), _BumpScale); //Changed UnpackNormal to UnpackScaleNormal
	            half3 snowNormal = half3(0, 0, 0);
	           	
	            // Snow mask
	            half snowMask = dot(WorldNormalVector(IN, o.Normal), _SnowDirection);
	            snowMask = pow(0.5 * snowMask + 0.5, 2.0);

	            o.Albedo = mainDiffuse.rgb * _Color;

	            if (snowMask >= lerp(1, 0, _SnowAmount))
	            {
	                o.Albedo = (snowDiffuse.rgb + 0.5) * 1 * _SnowColor * (snowprintsDiffuse);// + _SnowPrintsColor);
	                snowNormal = UnpackScaleNormal(tex2D(_SnowBump, IN.uv_SnowBump), _SnowBumpScale); //Changed UnpackNormal to UnpackScaleNormal
	                o.Normal = normalize(o.Normal + snowNormal);
	      		}
	       		
	            o.Alpha = mainDiffuse.a;
	        }

        ENDCG
    }
    FallBack "Diffuse"
    CustomEditor "CSA_SnowGUI"
}