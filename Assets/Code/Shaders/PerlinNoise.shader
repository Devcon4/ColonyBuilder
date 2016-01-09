Shader "Devcon/PerlinNoise" {
	Properties{
		_MainTex("Color (RGB) Alphha (A)", 2D) = "white" {}
		_Ilumn("Ilumination", Vector) = (0.0, 0.0, 0.0, 1.0)

		_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0, 1.0)
		_Frq("Frequency", Float) = 1.0
		_Amp("Amplitude", Float) = 1.0
		_Oct("Gain", Int) = 1.0
		_Durration("Time", Float) = 1.0
	}
		SubShader{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }

		CGPROGRAM
#pragma surface surf Lambert vertex:vert alpha
#include "PNNG.cginc"
		
	struct Input {
		float2 uv_MainTex;
		float4 color : COLOR;
	};
	// Access the shaderlab properties
	sampler2D _MainTex;
	float4 _Ilumn;
	float3 _SamplePos;
	float4 _Color;

	uniform float _Durration;
	uniform float _Frq;
	uniform float _Amp;
	uniform int _Oct;

	// Vertex modifier function
	void vert(inout appdata_full v) {
		// Do whatever you want with the "vertex" property of v here
		float3 worldPos = normalize(mul(_Object2World, v.vertex).xyz);
		worldPos += _SamplePos;
		worldPos *= _Time * _Durration;
		float noise = FractalNoise(worldPos.x, worldPos.y, worldPos.z, _Oct, _Frq, _Amp);
		v.vertex.xyz += v.normal * noise;

		float3 normalDirection = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
		float3 lightDirection;
		float atten = 1.0;

		lightDirection = normalize(_WorldSpaceLightPos0.xyz);

		float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
		float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

		v.color = float4(lightFinal * _Color.rgb, 1.0);
		v.color.a = _Color.a;
	}

	// Surface shader function
	void surf(Input IN, inout SurfaceOutput o) {
		o.Albedo = IN.color * _Ilumn;
		o.Alpha = IN.color.a;
	}

	ENDCG
	}
}