Shader "Devcon/Moon-1" {



	Properties{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0,1.0)
		_CFactor("Sharpness", Float) = 1.0
		_TexColor("TexColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainColor("MainColor", Color) = (1.0, 1.0, 1.0, 1.0)
		_FrqHeight("FrequencyHeight", Float) = 1.0
		_AmpHeight("AmplitudeHeight", Float) = 1.0
		_OctHeight("GainHeight", Int) = 1.0
		_FrqTex("FrequencyTex", Float) = 1.0
		_AmpTex("AmplitudeTex", Float) = 1.0
		_OctTex("GainTex", Int) = 1.0
	}

		SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Opaque" "LightMode" = "ForwardBase" }
		ZWrite On Lighting On Cull Off Fog{ Mode Off }
		GrabPass{ "_GrabTexture" }

		Pass
	{
		CGPROGRAM
		#pragma fragmentoption ARB_precision_hint_fastest
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile_fwdbase
		#include "AutoLight.cginc"
		#include "UnityCG.cginc"
		#include "SNNG.cginc"

		float4 _SamplePos;
		float _CFactor;
		half4 _TexColor;
		float4 _MainColor;
		uniform float _FrqHeight;
		uniform float _AmpHeight;
		uniform int _OctHeight;
		uniform float _FrqTex;
		uniform float _AmpTex;
		uniform int _OctTex;
		sampler2D _MainTex;
		sampler2D _GrabTexture;

		struct vertInput {
			float4 pos : POSITION;
			float4 color : COLOR;
			float2 texcoord : TEXCOORD0;
			float3 normal : NORMAL;
		};

		struct vertOutput {
			float4 pos : POSITION;	// Clip space
			float4 color : COLOR;		// Vertex colour
			float2 texcoord : TEXCOORD0;	// UV data

			float4 wPos : TEXCOORD1;	// World position
			float4 sPos : TEXCOORD2;	// Screen position
			float4 cPos : TEXCOORD3;	// Object center in world

			float4 uvgrab : TEXCOORD4;

			LIGHTING_COORDS(5, 6)
		};

		// Vertex function 
		vertOutput vert(appdata_full v)
		{ 
			vertOutput o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.color = v.color;

			o.texcoord = v.texcoord;

			o.wPos = mul(_Object2World, v.vertex);
			o.sPos = ComputeScreenPos(v.vertex);
			o.cPos = mul(_Object2World, half4(0, 0, 0, 1));

			//float4 worldPos = mul(_Object2World, v.pos);
			//float4 newPos = worldPos + _SamplePos;
			o.wPos += _SamplePos;
			float noise = FractalNoise(o.wPos, _OctHeight, _FrqHeight, _AmpHeight);
			o.pos.y += round(noise);

			/*lightDirection = normalize(_WorldSpaceLightPos0.xyz);

			float3 diffuseReflection = atten * max(0.0, dot(normalDirection, lightDirection));
			float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

			float cFactor = saturate(noise / (2 * _CFactor) + 0.5);

			o.color = float4(lightFinal * v.color.rgb, 1.0);*/

			o.uvgrab = ComputeGrabScreenPos(o.pos);

			TRANSFER_VERTEX_TO_FRAGMENT(o);

			float3 normalDirection = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
			float3 lightDirection;
			float atten = 1.0;

			lightDirection = normalize(_WorldSpaceLightPos0.xyz);

			float3 diffuseReflection = atten * _MainColor.xyz * max(0.0, dot(normalDirection, lightDirection));
			float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

			o.color = float4(lightFinal * v.color.rgb, 1.0);

			return o;
		}

		// Fragment function
		half4 frag(vertOutput i) : COLOR
		{
			half4 mainColor = tex2D(_MainTex, i.texcoord);
			fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
			float noise = FractalNoise(i.wPos, _OctTex, _FrqTex, _AmpTex);

			half4 noiseColor = lerp(_MainColor, _TexColor, noise);

			float attenuation = LIGHT_ATTENUATION(i);

			return _MainColor * attenuation;
		}
			ENDCG
		}
	}
	FallBack "VertexLit"
}
