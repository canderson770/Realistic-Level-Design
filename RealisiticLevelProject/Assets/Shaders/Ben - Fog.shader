Shader "Ben/Fog"
{
    Properties
    {
        [Header(Textures and color)]
        [Space(10)]
        _MainTex ("Fog texture", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _Color ("Color", color) = (1., 1., 1., 1.)
        //[Space()]
 
        [Header(Fog Properties)]
        [Space(10)]
        _ScrollDirX ("X Axis Movement", Range(-1., 1.)) = 1.
        _ScrollDirY ("Y Axis Movement", Range(-1., 1.)) = 1.
		//[PowerSlider(3.0)]
        _Speed ("Speed", Range(-5,5)) = 1.
        _Distance ("Fading distance", Range(0, 10.)) = 1.
		_RedReduce("Fix Red", Range (0,5)) = 0

        [Space(10)]
        _Cull ("Cull", float) = 0
    }
 
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull [_Cull]
 
        Pass
        {
		
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           
            #include "UnityCG.cginc"
			
 
            struct v2f {
                float4 pos : SV_POSITION;
                fixed4 vertCol : COLOR0;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
 
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv2 = v.texcoord;
                o.vertCol = v.color;
                return o;
            }
 
            float _Distance;
            sampler2D _Mask;
            float _Speed;
            fixed _ScrollDirX;
            fixed _ScrollDirY;
            fixed4 _Color;
			float _RedReduce;
 
            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv + fixed2(-_ScrollDirX, -_ScrollDirY) * _Speed * _Time.x;
                fixed4 col = tex2D(_MainTex, uv) * _Color * i.vertCol;
                col.a *= tex2D(_Mask, i.uv2).r;
                col.a *= 1 - ((i.pos.z / i.pos.w) * _Distance);
				clip(col.b - (i.pos.z / i.pos.w) * _RedReduce);
                return col;
            }
            ENDCG
        }
    }
}