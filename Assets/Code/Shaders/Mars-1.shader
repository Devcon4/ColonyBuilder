Shader "Devcon/Mars-1" {
	Properties{
		_SamplePos("SamplePosition", Vector) = (1.0,1.0,1.0,1.0)
		_BaseColor("TexColor", Color) = (1.0, 1.0, 1.0, 1.0)

		_FrqHeight("FrequencyHeight", Float) = 1.0
		_AmpHeight("AmplitudeHeight", Float) = 1.0
		_OctHeight("GainHeight", Int) = 1.0
	}
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass{
			tags { "LightMode" = "ForwardBase"}
			CGPROGRAM

				#pragma target 3.0	
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase

				#include "UnityLightingCommon.cginc"
				#include "UnityCG.cginc"
				#include "SNNG.cginc"

				float4 _SamplePos;
				half4 _BaseColor;
				uniform float _FrqHeight;
				uniform float _AmpHeight;
				uniform int _OctHeight;

				struct vertStruct {
					float4 vertex : POSITION;
					float4 tangent : TANGENT;
					float3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					fixed4 color : COLOR;
				};

				vertStruct vert(vertStruct v) {
					vertStruct o;

					o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

					float4 v1 = o.vertex;
					float4 v2 = o.vertex;

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
					o.vertex.y += round(noise);

					noisePosv1 += _SamplePos;
					float noisev1 = FractalNoise(noisePosv1, _OctHeight, _FrqHeight, _AmpHeight);
					v1.y += round(noisev1);
					
					noisePosv2 += _SamplePos;
					float noisev2 = FractalNoise(noisePosv2, _OctHeight, _FrqHeight, _AmpHeight);
					v2.y += round(noisev2);

					float3 vwn = cross(v2 - firstPos, v1 - firstPos);

					o.normal = vwn.xyz;

					float3 normalDirection = normalize(mul(float4(o.normal, 0.0), _World2Object).xyz);
					float3 lightDirection;
					float atten = 1.0;

					lightDirection = normalize(_WorldSpaceLightPos0.xyz);

					float3 diffuseReflection = atten * _BaseColor.xyz * max(0.0, dot(normalDirection, lightDirection));
					float3 lightFinal = diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;

					o.color = float4(lightFinal * v.color.rgb, 1.0);

					return o;
				}

				fixed4 frag(vertStruct i) : COLOR {

					fixed4 c = 0;

					c.rgb = UnityObjectToWorldNormal(i.normal)*0.5 + 0.5;

					return i.color;
				}

			ENDCG
		}

	}

	FallBack "Diffuse"
}
