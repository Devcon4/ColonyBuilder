Shader "Devcon/SimplexNoise" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0, 1.0)
		_Frq("Frequency", Float) = 1.0
		_Amp("Amplitude", Float) = 1.0
		_Oct("Gain", Int) = 1.0
		_Durration("Time", Float) = 1.0
	}
		SubShader{
		//Tags{ "RenderType" = "Transparent" }

		CGPROGRAM
#pragma surface surf Lambert vertex:vert
#include "SNNG.cginc"
		
	struct Input {
		float2 uv_MainTex;
	};
	// Access the shaderlab properties
	sampler2D _MainTex;
	float3 _SamplePos;

	uniform float _Durration;
	uniform float _Frq;
	uniform float _Amp;
	uniform int _Oct;

	// Vertex modifier function
	void vert(inout appdata_full v) {
		// Do whatever you want with the "vertex" property of v here
		float3 worldPos = normalize(mul(_Object2World, v.vertex).xyz);
		worldPos += _SamplePos;
		float4 finalPos = float4(worldPos.x, worldPos.y, worldPos.z, _Time.y * _Durration);
		float noise = FractalNoise(finalPos, _Oct, _Frq, _Amp);
		v.vertex.xyz += mul(_World2Object, v.normal * noise).xyz;
	}

	// Surface shader function
	void surf(Input IN, inout SurfaceOutput o) {
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
	}

	ENDCG
	}
}