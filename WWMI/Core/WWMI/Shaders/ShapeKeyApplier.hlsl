// Shader: WWMI Shape Key Applier
// Version: 1.0
// Creator: SpectumQT
// Comment: Adds per-vertex xyz offsets resulted from shape keys calculation to position buffer data

Texture1D<float4> IniParams : register(t120);

#define VertexOffset IniParams[0].x
#define VertexCount IniParams[0].y

Buffer<float3> PositionData : register(t6);
RWBuffer<float> ShapeKeyData : register(u0);
RWBuffer<float> PositionDataRW : register(u6);
RWBuffer<float4> DebugRW : register(u7);


[numthreads(64,1,1)]
void main(uint3 vThreadID : SV_DispatchThreadID)
{
  float4 positions, shape_key_vertex_offsets;

  if (vThreadID.x >= uint(VertexCount)) {
    return;
  }
  uint vertex_id = vThreadID.x + uint(VertexOffset);

  // Position load
  uint pos_id = vertex_id * 3;
  positions.xyz = PositionData.Load(vertex_id + 0).xyz;
  positions.w = 0;

  // Shape Keys data load
  uint key_id = vertex_id * 6;
  shape_key_vertex_offsets.x = ShapeKeyData.Load(key_id + 0).x;
  shape_key_vertex_offsets.y = ShapeKeyData.Load(key_id + 1).x;
  shape_key_vertex_offsets.z = ShapeKeyData.Load(key_id + 2).x;
  shape_key_vertex_offsets.w = 0;

  // Apply Shape Keys Coords Offsets
  positions.xyz = positions.xyz + shape_key_vertex_offsets.xyz;

  // Output
  PositionDataRW[pos_id + 0].x = positions.x;
  PositionDataRW[pos_id + 1].x = positions.y;
  PositionDataRW[pos_id + 2].x = positions.z;

  return;
}