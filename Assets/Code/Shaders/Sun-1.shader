Shader "Devcon/Sun-1" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Ilumn("Ilumination", Vector) = (0.0, 0.0, 0.0, 1.0)

		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0, 1.0)
		_Frq("Frequency", Float) = 1.0
		_Amp("Amplitude", Float) = 1.0
		_Oct("Gain", Int) = 1.0
		_Durration("Time", Float) = 1.0

		_CFactor("Sharpness", Float) = 1.0
		_Color1("Color1", Color) = (1.0, 1.0, 1.0, 1.0)
		_Color2("Color2", Color) = (0.0, 0.0, 0.0, 1.0)
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }

		CGPROGRAM
#pragma surface surf Lambert vertex:vert
#include "SNNG.cginc"
		
	struct Input {
		float2 uv_MainTex;
		float4 color : COLOR;
	};
	// Access the shaderlab properties
	sampler2D _MainTex;
	float4 _Ilumn;
	float3 _SamplePos;

	uniform float _Durration;
	uniform float _Frq;
	uniform float _Amp;
	uniform int _Oct;

	float _CFactor;
	float4 _Color1;
	float4 _Color2;

	// Vertex modifier function
	void vert(inout appdata_full v) {
		// Do whatever you want with the "vertex" property of v here
		float3 worldPos = normalize(mul(v.vertex, _Object2World).xyz);
		worldPos += _SamplePos;
		float4 finalPos = float4(worldPos.x, worldPos.y, worldPos.z, _Time.y * _Durration);
		float noise = FractalNoise(finalPos, _Oct, _Frq, _Amp);
		v.vertex.xyz += v.normal * noise;

		float cFactor = saturate(noise / (2 * _CFactor) + 0.5);

		v.color *= lerp(_Color1, _Color2, cFactor);
	}

	// Surface shader function
	void surf(Input IN, inout SurfaceOutput o) {
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * IN.color * _Ilumn;
	}

	ENDCG
	}
}