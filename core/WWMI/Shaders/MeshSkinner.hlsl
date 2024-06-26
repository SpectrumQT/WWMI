// Shader: WWMI Mesh Skinner
// Version: 1.0
// Creator: SpectumQT
// Comment: It's original Animated Pose CS decompiled from ASM with few tweaks:
// * Added 32-bit weights support
// * Replaced CB-based config with IniParams vars
// * Disabled logic that isn't used by the game

Texture1D<float4> IniParams : register(t120);

#define VertexOffset IniParams[0].x
#define VertexCount IniParams[0].y
#define MeshScale IniParams[0].z

cbuffer cb0 : register(b0)
{
  float4 cb0[2];
}

Buffer<float4> t1 : register(t1);

Buffer<float4> t2 : register(t2);

Buffer<float> t3 : register(t3);

Buffer<uint4> t4 : register(t4);

Buffer<snorm float4> t5 : register(t5);

Buffer<float4> t6 : register(t6);

RWBuffer<snorm float4> u0 : register(u0);
RWBuffer<float4> u1 : register(u1);
RWBuffer<float4> t0 : register(u6);
// RWBuffer<float4> DebugRW : register(u7);


[numthreads(64,1,1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  float4 r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15,r16;
  uint4 bitmask;

  if (vThreadID.x >= uint(VertexCount)) {
    return;
  }
  uint vertex_id = vThreadID.x + uint(VertexOffset);

  // Vectors load
  r1.xy = (uint2)vertex_id << int2(1,1);
  r2.xyzw = t5.Load(r1.x).xyzw;
  bitmask.x = ((~(-1 << 31)) << 1) & 0xffffffff;
  r1.x = (((uint)vertex_id << 1) & bitmask.x) | ((uint)1 & ~bitmask.x);
  bitmask.z = ((~(-1 << 31)) << 1) & 0xffffffff;
  r1.z = (((uint)vertex_id << 1) & bitmask.z) | ((uint)1 & ~bitmask.z);
  r3.xyzw = t5.Load(r1.x).xyzw;

  // Blends load
  uint data_id = vertex_id * 2;
  uint4 vertex_group_ids = t4[data_id];
  unorm float4 weights = asfloat(t4[data_id+1]);

  r1.wx = vertex_group_ids.xw;
  r4.xyzw = vertex_group_ids.yyzz;
  r5.xyz = weights.xyz;
  r0.x = weights.w;

  // Shape Keys data load
  r6.xyz = (int3)vertex_id * int3(6,3,3);
  r7.x = t3.Load(r6.x).x;
  r5.w = mad((int)vertex_id, 6, 1);
  r7.y = t3.Load(r5.w).x;
  r8.xyzw = mad((int4)vertex_id, int4(6,6,6,6), int4(2,3,4,5));
  r7.z = t3.Load(r8.x).x;
  r9.x = t3.Load(r8.y).x;
  r9.y = t3.Load(r8.z).x;
  r9.z = t3.Load(r8.w).x;

  // Zeroed buffers handling, unknown behaviour, thus commented out
  // r6.xw = asint(cb0[0].xx) & int2(1,2);
  // if (r6.x != 0) {
  //   r8.x = t1.Load(r6.y).x;
  //   r10.xy = mad((int2)r0.zz, int2(3,3), int2(1,2));
  //   r8.y = t1.Load(r10.x).x;
  //   r8.z = t1.Load(r10.y).x;
  // } else {
    // r8.xyz = float3(0,0,0);
  // }
  // if (r6.w != 0) {
  //   r10.x = t2.Load(r6.y).x;
  //   r6.xw = mad((int2)r0.zz, int2(3,3), int2(1,2));
  //   r10.y = t2.Load(r6.x).x;
  //   r10.z = t2.Load(r6.w).x;
  // } else {
    // r10.xyz = float3(0,0,0);
  // }

  // Skeleton load
  r0.y = (int)r1.w * 3;
  r11.xyzw = t0.Load(r0.y).xyzw;
  r6.xw = mad((int2)r1.ww, int2(3,3), int2(1,2));
  r12.xyzw = t0.Load(r6.x).xyzw;
  r13.xyzw = t0.Load(r6.w).xyzw;
  r6.xw = (int2)r4.yw * int2(3,3);
  r14.xyzw = t0.Load(r6.x).xyzw;
  r4.xyzw = mad((int4)r4.xyzw, int4(3,3,3,3), int4(1,2,1,2));
  r15.xyzw = t0.Load(r4.x).xyzw;
  r16.xyzw = t0.Load(r4.y).xyzw;
  r14.xyzw = r14.xyzw * r5.yyyy;
  r15.xyzw = r15.xyzw * r5.yyyy;
  r16.xyzw = r16.xyzw * r5.yyyy;
  r11.xyzw = r5.xxxx * r11.xyzw + r14.xyzw;
  r12.xyzw = r5.xxxx * r12.xyzw + r15.xyzw;
  r13.xyzw = r5.xxxx * r13.xyzw + r16.xyzw;
  r14.xyzw = t0.Load(r6.w).xyzw;
  r15.xyzw = t0.Load(r4.z).xyzw;
  r4.xyzw = t0.Load(r4.w).xyzw;
  r11.xyzw = r5.zzzz * r14.xyzw + r11.xyzw;
  r12.xyzw = r5.zzzz * r15.xyzw + r12.xyzw;
  r4.xyzw = r5.zzzz * r4.xyzw + r13.xyzw;
  r0.y = (int)r1.x * 3;
  r5.xyzw = t0.Load(r0.y).xyzw;
  r1.xw = mad((int2)r1.xx, int2(3,3), int2(1,2));
  r13.xyzw = t0.Load(r1.x).xyzw;
  r14.xyzw = t0.Load(r1.w).xyzw;
  r5.xyzw = r0.xxxx * r5.xyzw + r11.xyzw;
  r11.xyzw = r0.xxxx * r13.xyzw + r12.xyzw;
  r4.xyzw = r0.xxxx * r14.xyzw + r4.xyzw;

  // Position load
  r6.x = t6.Load(r6.y).x;
  r0.xyzw = mad((int4)vertex_id, int4(3,3,3,3), int4(1,2,1,2));
  r6.y = t6.Load(r0.x).x;
  r6.w = t6.Load(r0.y).x;
  r6.xyw = r7.xyz + r6.xyw;

  // Skinning
  r7.xyz = r9.xyz + r3.xyz;
  r0.x = dot(r7.xyz, r7.xyz);
  r0.x = rsqrt(r0.x);
  r7.xyz = r7.xyz * r0.xxx;
  r0.x = dot(r2.xyz, r7.xyz);
  r9.xyz = -r0.xxx * r7.xyz + r2.xyz;
  r0.x = dot(r9.xyz, r9.xyz);
  r0.x = rsqrt(r0.x);
  r9.xyz = r9.xyz * r0.xxx;
  // r8.xyz = r6.xyw + r8.xyz;
  r8.xyz = r6.xyw;
  r8.w = 1;
  r12.x = dot(r5.xyzw, r8.xyzw);
  r12.y = dot(r11.xyzw, r8.xyzw);
  r12.z = dot(r4.xyzw, r8.xyzw);
  // r6.xyw = r12.xyz * cb0[1].www + r10.xyz;
  r6.xyw = r12.xyz * MeshScale;
  r8.x = dot(r5.xyz, r9.xyz);
  r8.y = dot(r11.xyz, r9.xyz);
  r8.z = dot(r4.xyz, r9.xyz);
  r0.x = dot(r8.xyz, r8.xyz);
  r0.x = rsqrt(r0.x);
  r2.xyz = r8.xyz * r0.xxx;
  r5.x = dot(r5.xyz, r7.xyz);
  r5.y = dot(r11.xyz, r7.xyz);
  r5.z = dot(r4.xyz, r7.xyz);
  r0.x = dot(r5.xyz, r5.xyz);
  r0.x = rsqrt(r0.x);
  r3.xyz = r5.xyz * r0.xxx;

  // Output
  u1[r6.z].xyzw = r6.xxxx;
  u1[r0.z].xyzw = r6.yyyy;
  u1[r0.w].xyzw = r6.wwww;
  u0[r1.y].xyzw = r2.xyzw;
  u0[r1.z].xyzw = r3.xyzw;

  return;
}