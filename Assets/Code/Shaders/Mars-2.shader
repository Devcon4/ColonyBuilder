Shader "Custom/Mars-2" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0,1.0)

		_FrqHeight("FrequencyHeight", Float) = 1.0
		_AmpHeight("AmplitudeHeight", Float) = 1.0
		_OctHeight("GainHeight", Int) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
#pragma vertex vert

#include "SNNG.cginc"

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		float4 _SamplePos;
		uniform float _FrqHeight;
		uniform float _AmpHeight;
		uniform int _OctHeight;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		void vert(inout appdata_full v) {

			float4 originalPos = mul(UNITY_MATRIX_MVP, v.vertex);
			
			float4 v1 = v.vertex;
			float4 v2 = v.vertex;

			v1.xyz += float3(0.5, 0, 0);
			v2.xyz += float3(0, 0, 0.5);

			float4 v1L = v.vertex;
			float4 v2L = v.vertex;

			v1L.xyz += float3(0.5, 0, 0);
			v2L.xyz += float3(0, 0, 0.5);

			//v1L = mul(UNITY_MATRIX_MVP, v1L);
			//v2L = mul(UNITY_MATRIX_MVP, v2L);

			float4 firstPos = mul(_Object2World, v.vertex);

			float4 noisePos = mul(_Object2World, v.vertex);
			float4 noisePosv1 = mul(_Object2World, v1L);
			float4 noisePosv2 = mul(_Object2World, v2L);

			//float3 noisePos = v.vertex;
			//float3 noisePosv1 = v1L;
			//float3 noisePosv2 = v2L;

			noisePos += _SamplePos;
			float noise = FractalNoise(noisePos, _OctHeight, _FrqHeight, _AmpHeight);
			originalPos.y += round(noise);

			noisePosv1 += _SamplePos;
			float noisev1 = FractalNoise(noisePosv1, _OctHeight, _FrqHeight, _AmpHeight);
			v1.y += round(noisev1);

			noisePosv2 += _SamplePos;
			float noisev2 = FractalNoise(noisePosv2, _OctHeight, _FrqHeight, _AmpHeight);
			v2.y += round(noisev2);

			float3 vwn = cross(v2 - firstPos, v1 - firstPos);

			v.normal = UnityObjectToWorldNormal(vwn.xyz);
			v.vertex = originalPos;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
