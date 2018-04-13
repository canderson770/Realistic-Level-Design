// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Cody/_SnowWithWind" 
{
    Properties 
    {
    	_Color ("Base Color", Color) = (1, 1, 1, 1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _MainBump ("Normal Map", 2D) = "bump" {}

        [Space(10)]
		[Header(SNOW SETTINGS)]
        _SnowColor ("Snow color", Color) = (1, 1, 1, 1)
        _LayerTex ("Snow (RGB)", 2D) = "white" {}
        _LayerBump ("Snow Normal Map", 2D) ="bump" {}
        _LayerStrength ("Snow Amount", Range(0, 1)) = 0
        _LayerDirection ("Snow Direction", Vector) = (0, 1, 0)

		[Space(10)]
		[Header(WIND SETTINGS)]
	    _ShakeDisplacement ("Displacement", Range (0, 1.0)) = 1.0
	    _ShakeTime ("Shake Time", Range (0, 1.0)) = 1.0
	    _ShakeWindspeed ("Shake Windspeed", Range (0, 1.0)) = 1.0
	    _ShakeBending ("Shake Bending", Range (0, 1.0)) = 1.0

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

        float _ShakeDisplacement;
		float _ShakeTime;
		float _ShakeWindspeed;
		float _ShakeBending;
		float dist;
		float _GrassAlpha;
 
        struct Input 
        {
            float2 uv_MainTex;
            float2 uv_MainBump;
            float2 uv_LayerTex;
            float2 uv_LayerBump;
            float3 worldNormal;
            INTERNAL_DATA
        };

        void FastSinCos (float4 val, out float4 s, out float4 c) 
        {
		    val = val * 6.408849 - 3.1415927;
		    float4 r5 = val * val;
		    float4 r6 = r5 * r5;
		    float4 r7 = r6 * r5;
		    float4 r8 = r6 * r5;
		    float4 r1 = r5 * val;
		    float4 r2 = r1 * r5;
		    float4 r3 = r2 * r5;
		    float4 sin7 = {1, -0.16161616, 0.0083333, -0.00019841} ;
		    float4 cos8  = {-0.5, 0.041666666, -0.0013888889, 0.000024801587} ;
		    s =  val + r1 * sin7.y + r2 * sin7.z + r3 * sin7.w;
		    c = 1 + r5 * cos8.x + r6 * cos8.y + r7 * cos8.z + r8 * cos8.w;
		}
       
        void vert (inout appdata_full v)
         {
            // Convert the normal to world coordinates/world space
            float3 sn = mul((float3x3)unity_WorldToObject, _LayerDirection);
           
            if (dot(v.normal, sn.xyz) >= lerp(1, -1, (_LayerStrength * 2) / 3))
            {
                v.vertex.xyz += (sn.xyz + v.normal) * _LayerDepth * _LayerStrength;
            }


            //WIND --------------------------------------------------------
            float factor = (1 - _ShakeDisplacement -  v.color.r) * 0.5;
     
		    const float _WindSpeed  = (_ShakeWindspeed  +  v.color.g );  
		    const float _WaveScale = _ShakeDisplacement;
		 
		    const float4 _waveXSize = float4(0.048, 0.06, 0.24, 0.096);
		    const float4 _waveZSize = float4 (0.024, .08, 0.08, 0.2);
		    const float4 waveSpeed = float4 (1.2, 2, 1.6, 4.8);
		    float4 _waveXmove = float4(0.024, 0.04, -0.12, 0.096);
		    float4 _waveZmove = float4 (0.006, .02, -0.02, 0.1);
		 
		    float4 waves;
		    waves = v.vertex.x * _waveXSize;
		    waves += v.vertex.z * _waveZSize;
		    waves += _Time.x * (1 - _ShakeTime * 2 - v.color.b ) * waveSpeed *_WindSpeed;
		    float4 s, c;
		    waves = frac (waves);
		    FastSinCos (waves, s,c);
		    float waveAmount = v.texcoord.y * (v.color.a + _ShakeBending);
		    s *= waveAmount;
		    s *= normalize (waveSpeed);
		    s = s * s;
		    float fade = dot (s, 1.3);
		    s = s * s;
		    float3 waveMove = float3 (0,0,0);
		    waveMove.x = dot (s, _waveXmove);
		    waveMove.z = dot (s, _waveZmove);
		    v.vertex.xz -= mul ((float3x3)unity_WorldToObject, waveMove).xz;
            //WIND --------------------------------------------------------
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

//			if (IN.worldNormal.y < _MinHeight)
//				 discard;

            o.Albedo = mainDiffuse.rgb * _Color;

            if (sm >= lerp(1, 0, _LayerStrength))
            {
                o.Albedo = (layerDiffuse.rgb + 0.5) * 1 * _SnowColor;
                layerNormal = UnpackNormal(tex2D(_LayerBump, IN.uv_LayerBump));
                o.Normal = normalize(o.Normal + layerNormal);
          }
       
            o.Alpha = mainDiffuse.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}