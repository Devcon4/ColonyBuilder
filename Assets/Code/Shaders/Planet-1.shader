Shader "Devcon/Planet-1" {
	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0, 1.0)
		_Frq("Frequency", Float) = 1.0
		_Amp("Amplitude", Float) = 1.0
		_Oct("Gain", Int) = 1.0
		_Durration("Time", Float) = 1.0

		_Color1("Color1", Color) = (1.0, 1.0, 1.0, 1.0)
		_Color2("Color2", Color) = (0.0, 0.0, 0.0, 1.0)
		_Color3("Color3", Color) = (1.0, 1.0, 1.0, 1.0)
		_Color4("Color4", Color) = (0.0, 0.0, 0.0, 1.0)
		_ColorTran("Color Transitions", Vector) = (0.0,0.0,0.0,0.0)
		_ColorShrp("Color Sharpness", Vector) = (0.5,0.5,0.5,0.5)
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
	float3 _SamplePos;

	uniform float _Durration;
	uniform float _Frq;
	uniform float _Amp;
	uniform int _Oct;

	float3 _ColorTran;
	float4 _ColorShrp;
	float4 _Color1;
	float4 _Color2;
	float4 _Color3;
	float4 _Color4;

	// Vertex modifier function
	void vert(inout appdata_full v) {
		// Do whatever you want with the "vertex" property of v here
		float3 worldPos = normalize(mul(v.vertex, _Object2World).xyz);
		worldPos += _SamplePos;
		//float4 finalPos = float4(worldPos.x, worldPos.y, worldPos.z);
		float noise = FractalNoise(worldPos, _Oct, _Frq, _Amp);
		v.vertex.xyz += v.normal * noise;

		float cFactor = saturate(noise / (2 * _ColorShrp.w));
		float4 lerpColor1 = _Color1;
		float4 lerpColor2 = _Color4;

		//noise = normalize(noise);
		//lerp by factor
		if (noise <= _ColorTran.x) {
			lerpColor2 = _Color2;
			cFactor = saturate(noise / (2 * _ColorShrp.x));
		}
		else if (noise <= _ColorTran.y) {
			lerpColor1 = _Color2;
			lerpColor2 = _Color3;
			cFactor = saturate(noise / (2 * _ColorShrp.y));
		}
		else if (noise <= _ColorTran.z) {
			lerpColor1 = _Color3;
			cFactor = saturate(noise / (2 * _ColorShrp.z));
		}

		v.color *= lerp(lerpColor1, lerpColor2, cFactor);

		float3 normalDirection = normalize(mul(float4(v.normal, 0.0), _World2Object).xyz);
		float3 lightDirection;
		float atten = 1.0;

		lightDirection = normalize(_WorldSpaceLightPos0.xyz);

		float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot(normalDirection, lightDirection));
		float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

		v.color = float4(lightFinal * v.color.rgb, 1.0);
		//v.sv_position = mul(UNITY_MATRIX_MVP, v.vertex);

	}

	// Surface shader function
	void surf(Input IN, inout SurfaceOutput o) {
		o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb * IN.color;
	}

	ENDCG
	}
}