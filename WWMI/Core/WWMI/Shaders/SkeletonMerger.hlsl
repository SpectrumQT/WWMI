
cbuffer Skeleton : register(b8)
{
  float4 Skeleton[768];
}

RWBuffer<float4> MergedSkeleton : register(u6);

// RWBuffer<float4> DebugRW : register(u7);

Texture1D<float4> IniParams : register(t120);

#define CustomMeshScale IniParams[1].x
#define VertexGroupOffset IniParams[1].z
#define VertexGroupCount IniParams[1].w


#ifdef COMPUTE_SHADER

[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    
int cb_vertex_offset = 0;

	int vg_id = ThreadId.x;

    if (vg_id >= VertexGroupCount) {
        return;
    }

    // DebugRW[VertexGroupOffset+vg_id] = Skeleton[vg_id];

    if (any(Skeleton[vg_id] != 0 || Skeleton[vg_id+1] != 0 || Skeleton[vg_id+2] != 0)) {
        vg_id *= 3;
        // 48 bytes per VG, 4 bytes per float, 4*3 floats per thread 
        int vg_offset = VertexGroupOffset * 3 + vg_id;

        MergedSkeleton[vg_offset] = Skeleton[vg_id] * CustomMeshScale;
        MergedSkeleton[vg_offset+1] = Skeleton[vg_id+1] * CustomMeshScale;
        MergedSkeleton[vg_offset+2] = Skeleton[vg_id+2] * CustomMeshScale;
    }

}

#endif