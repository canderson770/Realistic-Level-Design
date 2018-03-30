Shader "Cody/CombinedSnow" 
{
	Properties
	{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
        _MainBump ("MainBump2", 2D) = "bump" {}
        _LayerTex ("Snow", 2D) = "white" {}
        _LayerBump ("Snow Bump", 2D) ="bump" {}
		//_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}
		//_SnowRamp("Snow Toon Ramp (RGB)", 2D) = "gray" {}
		_SnowAngle("Snow Angle", Vector) = (0,1,0)

		//TOON
		_SnowColor("Toon Base Color", Color) = (0.5,0.5,0.5,1)
		_TColor("Toon Top Color", Color) = (0.5,0.5,0.5,1)
		_RimColor("Toon Rim Color", Color) = (0.5,0.5,0.5,1)
		_RimPower("Toon Rim Power", Range(0,4)) = 1
		_SnowSize("Toon Amount", Range(-2,2)) = .5
		_Height("Toon Height", Range(0,0.2)) = 0
		
		//REALISTIC
        _LayerStrength ("Realistic Strength", Range(0, 1)) = 0
//        _LayerDirection ("Realistic Direction", Vector) = (0, 1, 0)
        _LayerDepth ("OnOff", Range(0, 0.1)) = 0.0005

	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		Cull Off

       
    CGPROGRAM
	    #pragma target 3.0
	    #pragma surface surf Lambert vertex:vert

	    sampler2D _MainTex;
	    sampler2D _MainBump;
	    sampler2D _LayerTex;
	    sampler2D _LayerBump;
	    float _LayerStrength;
	    float3 _SnowAngle;
	    float _LayerDepth;

	    struct Input {
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
	        float3 sn = mul((float3x3)unity_WorldToObject, _SnowAngle);
	       
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
	        half sm = dot(WorldNormalVector(IN, o.Normal), _SnowAngle);
	        sm = pow(0.5 * sm + 0.5, 2.0);
	       
	        if (sm >= lerp(1, 0, _LayerStrength))
	        {
	            o.Albedo = (layerDiffuse.rgb + 0.5 * mainDiffuse.rgb) * 0.75;
	            layerNormal = UnpackNormal(tex2D(_LayerBump, IN.uv_LayerBump));
	            o.Normal = normalize(o.Normal + layerNormal);
	        }
	        else
	        {
	            o.Albedo = mainDiffuse.rgb;
	        }
	   
	        o.Alpha = mainDiffuse.a;
	        }

        ENDCG


        CGPROGRAM

		#pragma surface surf ToonRamp vertex:disp addshadow
		sampler2D _Ramp;

		// custom lighting function that uses a texture ramp based
		// on angle between light direction and normal
		#pragma lighting ToonRamp exclude_path:prepass

		inline half4 LightingToonRamp(SurfaceOutput s, half3 lightDir, half atten)
		{
			#ifndef USING_DIRECTIONAL_LIGHT
					lightDir = normalize(lightDir);
			#endif

			half d = dot(s.Normal, lightDir)*0.5 + 0.5;
			half3 ramp = tex2D(_Ramp, float2(d,d)).rgb;

			half4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
			c.a = 0;
			return c;
		}


		sampler2D _MainTex;
		sampler2D _SnowRamp;
		
		float4 _Color;
		float4 _SnowColor;
		float4 _TColor;
		float4 _SnowAngle;
		float4 _RimColor;

		float _SnowSize;
		float _Height;
		float _RimPower;

		struct Input 
		{
			float2 uv_MainTex : TEXCOORD0;
			float3 worldPos;
			float3 viewDir;
			float3 lightDir;
		
		};

		struct appdata {
			float4 vertex : POSITION;
			float3 normal : NORMAL;
		};

		void disp(inout appdata_full v, out Input o)
		{
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.lightDir = WorldSpaceLightDir(v.vertex); // light direction for snow ramp
			float4 snowC = mul(_SnowAngle , unity_ObjectToWorld); // snow direction convertion to worldspace
			if (dot(v.normal, snowC.xyz) >= _SnowSize )
			{
				v.vertex.xyz += v.normal * _Height;// scale vertices along normal
			}

		}

		void surf(Input IN, inout SurfaceOutput o) 
		{

			float3 localPos = (IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz); // local position for snow color blend
			half d = dot(o.Normal, IN.lightDir)*0.5 + 0.5; // light value for snow toon ramp
			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color; // main texture
			half3 rampS = tex2D(_SnowRamp, float2(d, d)).rgb; // snow toon ramp
			o.Albedo = c.rgb * _Color;// base color
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); // rimlight
			if (dot( o.Normal, _SnowAngle.xyz) >= _SnowSize -0.4) { // if dot product result is higher than snow amount, we turn it into snow
				o.Albedo = (lerp(_SnowColor * rampS, _TColor * rampS, saturate(localPos.y))); // blend base snow with top snow based on position
				o.Emission = _RimColor.rgb *pow(rim, _RimPower);// add glow rimlight to snow
			}
			o.Alpha = c.a;
		}
	ENDCG

	}Fallback "Diffuse"
}