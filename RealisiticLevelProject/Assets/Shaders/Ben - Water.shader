
Shader "Ben/Water"
{
  Properties 
  {
	_MainTex ("Texture", 2D) = "white" {}
//	_Metallic ("Metallic", Range(0,1)) = 0.0

  	_Refract ("Refraction Normal", 2D) = "" {}
	_DispTex("Displacement Map", 2D) = "gray"{}
	
	_DisplaceRange("Warping Speed", Range(0,10)) = 0.4
	_Amount("Amplitude", Range(-.4, .4)) = 0.1
	_Discolor("Color Range", Range (1.1,10)) = 5
  	_WaterLight("Water Light", Color) = (0.2,0.8,0.9,1)
  	_WaterDark ("Water Dark", Color) = (0.2,0.8,0.9,1)
  	
  	
  	
  	_DepthMax ("Opacity", Range(0,1)) = 0.9
  	_Distort ("Distortion", Range(0,1)) = 1
	_ScrollSpeedU("Scroll X Speed",float) = 2
	_ScrollSpeedV("Scroll Y Speed",float) = 0
  	_WaveShift ("Wave Shift", Range(0,3)) = 1
  }

  SubShader 
  {
    Tags { "Queue" = "Overlay" }
	GrabPass { "_background" }
    Pass 
    { 	
    	Cull Off
      	CGPROGRAM
      	#pragma target 3.0
      	#pragma vertex vert
      	#pragma fragment frag
      	#include "UnityCG.cginc"

		sampler2D _MainTex, _BumpMap;
		sampler2D _DispTex;
		sampler2D _CameraDepthTexture;
      	sampler2D _background;
      	sampler2D _Refract;
      	float4 _HighColor;
      	float4 _WaterLight;
      	float4 _WaterDark;
      	
      	float _DepthMax;
      	float _Distort;
      	float _WaveShift;
      	float _DisplaceRange;

		half _Metallic;

		
		fixed _ScrollSpeedU, _ScrollSpeedV;
		half _Amount, _Discolor;

		struct Input {
			float2 uv_DispTex;
		};

      	struct appdata {
      		float4 vertex : POSITION;
      		float2 uv : TEXCOORD0;
			float2 dispUv : TEXCOORD2;
			fixed4 normal: NORMAL;
      	};
   	
      	struct v2f 
      	{
        	float4 pos : SV_POSITION;
        	float4 screenpos : TEXCOORD1;
        	float2 uv : TEXCOORD0;
        	float3 viewdir : FLOAT;
			float2 uv_BumpMap :TEXCOORD3;
      	};
       
      	v2f vert(appdata v)
      	{         
        	v2f o;
			half3 disp = tex2Dlod(_DispTex, float4(v.dispUv, 0,0)).b;
			float time = (_Time[1] * disp.r) * _DisplaceRange; 
			float r = sin((_Time[1]) * (2 * 3.14)) * 0.5 + 0.25;
			float g = sin((_Time[1] + 0.33333333) * 2 * 3.14) * 0.5 + 0.25;
			float b = sin((_Time[1] + 0.66666667) * 2 * 3.14) * 0.5 + 0.25;
			float correction = 1 / (r + g + b);
			r *= correction;
			g *= correction;
			b *= correction;
			float d = (disp.r * r + disp.g * g + disp.b * b);
			v.vertex.xyz += (v.normal * sin(d + time) * _Amount);
        	o.pos = UnityObjectToClipPos(v.vertex);
        	o.screenpos = ComputeScreenPos(o.pos);
        	o.uv = v.uv;
//        	o.Metallic = _Metallic;

			
			//o.pos = UnityObjectToClipPos(v.vertex);
        	// calculating viewdirection on vertex
        	//o.viewdir = UnityObjectToClipPos(v.vertex);
			o.uv.x += _Time * _ScrollSpeedU;
			o.uv.y += _Time * _ScrollSpeedV;
        	return o;
      	}

      	fixed4 frag(v2f i) : COLOR 
      	{
			
      		// wave shift
      		float2 waveshift = float2(1, 0) * _Time;

			// calculating refraction from normals
			float3 n1 = UnpackNormal(tex2D(_Refract, i.uv + waveshift));
			float3 n2 = UnpackNormal(tex2D(_Refract, i.uv - waveshift));
			float3 normals = (n1 + n2) /2;
			float2 refr = normals.xy * 0.2 * _Distort;

			// calculating fresnel from lightdirection and normal reflection
			float3 reflective = reflect(_WorldSpaceLightPos0, normals);
			float fresnel = -dot(i.viewdir, reflective)/2 +0.5;
		
			// screenspace coordinates with offset
			float4 screen = float4(i.screenpos.xy + refr, i.screenpos.zw);

			// calculating depth with offset for frag and scene
			float sceneZ = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(screen)));
			float fragZ = screen.z;

			// masking out the refraction for objects above water surface
			float mask = step(fragZ, sceneZ);
			float2 refrmasked = refr * mask;

			// screenspace coordinates with masked offset
			float4 screen_masked = float4(i.screenpos.xy + refrmasked, i.screenpos.zw);

			// calculating depth with masked offset for scene
            float sceneZ_masked = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(screen_masked)));

			// difference between fragz and scenez
            float vis = (sceneZ_masked - fragZ); 
            if (vis > _DepthMax) vis = _DepthMax;

			// adding masked refraction offset
			half4 background = tex2Dproj(_background, UNITY_PROJ_COORD(screen_masked));

			float2 uv = i.uv;
			float3 noise = tex2D(_DispTex, i.uv);
			half4 c = tex2D(_MainTex, uv);

			float r = sin((_Time[1]) * (2 * 3.14)) * 0.5 + 0.25;
			float g = sin((_Time[1] + 0.33333333) * 2 * 3.14) * 0.5 + 0.25;
			float b = sin((_Time[1] + 0.66666667) * 2 * 3.14) * 0.5 + 0.25;
			float correction = 1 / (r + g + b);
			r *= correction;
			g *= correction;
			b *= correction;
			if(r<-.2)r=-.2;
			if(g<-.2)g=-.2;
			if(b<-.2)b=-.2;
			
			float n = (saturate(noise.r) *r + saturate(noise.g) *g + saturate(noise.b) *b) /_Discolor;
			half4 watercolor = tex2D(_MainTex, float2(n,0.5)) + lerp(_WaterDark, _WaterLight, fresnel);

			// adding depth
            half4 waterdepth = lerp(background, watercolor, vis);

            // adding highlights
            half4 water = lerp(waterdepth, _WaterDark, pow(fresnel, 10));


            return water;
      	}
      	ENDCG
    	}
  	}
}