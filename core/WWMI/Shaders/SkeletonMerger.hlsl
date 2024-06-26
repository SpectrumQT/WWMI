

cbuffer cb0 : register(b0)
{
  uint4 cb0[2];
}

Buffer<float4> Skeleton : register(t0);

RWBuffer<float4> MergedSkeleton : register(u6);

// RWBuffer<float4> DebugRW : register(u7);


Texture1D<float4> IniParams : register(t120);

#define ConstantBufferFromat IniParams[0].x
#define VertexOffset IniParams[1].x
#define VertexCount IniParams[1].y
#define VertexGroupOffset IniParams[1].z
#define VertexGroupCount IniParams[1].w


#ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    
int cb_vertex_offset = 0;

    int cb_vertex_count = 0;

    if (ConstantBufferFromat == 0) {
        cb_vertex_offset = cb0[0].y;
        cb_vertex_count = cb0[0].w;

    } else {
        cb_vertex_offset = cb0[0].y;
        cb_vertex_count = cb0[1].x;
    }

    if (cb_vertex_offset != VertexOffset || cb_vertex_count != VertexCount) {
        return;
    }


	int vg_id = ThreadId.x;

    if (vg_id >= VertexGroupCount) {
        return;
    }


    // DebugRW[vg_id] = float4(1,1,1,1);

    // DebugRW[VertexGroupOffset+vg_id] = float4(VertexOffset, VertexCount, VertexGroupOffset, VertexGroupCount);

    if (any(Skeleton[vg_id] != 0 || Skeleton[vg_id+1] != 0 || Skeleton[vg_id+2] != 0)) {
        vg_id *= 3;
        // 48 bytes per VG, 4 bytes per float, 4*3 floats per thread 
        int vg_offset = VertexGroupOffset * 3 + vg_id;

        MergedSkeleton[vg_offset] = Skeleton[vg_id];
        MergedSkeleton[vg_offset+1] = Skeleton[vg_id+1];
        MergedSkeleton[vg_offset+2] = Skeleton[vg_id+2];
    }




}

#endif