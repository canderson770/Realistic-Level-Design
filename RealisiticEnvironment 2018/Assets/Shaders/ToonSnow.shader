
Shader "Cody/Snow/Toon Snow" {
	Properties{
		_Color("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex("Base (RGB)", 2D) = "white" {}
        _MainBump ("MainBump2", 2D) = "bump" {}

//		_Ramp("Toon Ramp (RGB)", 2D) = "gray" {}
	//	_SnowRamp("Snow Toon Ramp (RGB)", 2D) = "gray" {}
		_SnowAngle("Snow Angle", Vector) = (0,1,0)
		_SnowColor("Snow Base Color", Color) = (0.5,0.5,0.5,1)
		_TColor("Snow Top Color", Color) = (0.5,0.5,0.5,1)
		_RimColor("Snow Rim Color", Color) = (0.5,0.5,0.5,1)
		_RimPower("Snow Rim Power", Range(0,4)) = 3
		_SnowSize("Snow Amount", Range(-2,2)) = 1 
		_Height("Snow Height", Range(0,0.2)) = 0.1
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200
		Cull Off

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
		sampler2D _Bump;
		
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
			float2 uv_Bump;
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
//            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
//            o.Normal = UnpackNormal (tex2D(_Bump, IN.uv_Bump));

			float3 localPos = (IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz); // local position for snow color blend

			half3 normalM = o.Normal;

			half d = dot(normalM, IN.lightDir)*0.5 + 0.5; // light value for snow toon ramp

			//o.Normal = UnpackNormal (tex2D(_Bump, IN.uv_Bump));

			half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color; // main texture
			half3 rampS = tex2D(_SnowRamp, float2(d, d)).rgb; // snow toon ramp
			o.Albedo = c.rgb * _Color;// base color
			half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); // rimlight
			if (dot( normalM, _SnowAngle.xyz) >= _SnowSize -0.4) { // if dot product result is higher than snow amount, we turn it into snow
				o.Albedo = (lerp(_SnowColor * rampS, _TColor * rampS, saturate(localPos.y))); // blend base snow with top snow based on position
				o.Emission = _RimColor.rgb *pow(rim, _RimPower);// add glow rimlight to snow
			}
			o.Alpha = c.a;
		}
	ENDCG

	}

		Fallback "Diffuse"
}