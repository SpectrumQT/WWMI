

RWBuffer<float4> DebugRW : register(u1);

Texture1D<float4> IniParams : register(t120);

[numthreads(1,1,1)]
void main(uint3 DTid : SV_DispatchThreadID)
{
    DebugRW[0] = IniParams[100].xyzw;
    DebugRW[1] = IniParams[101].xyzw;
    DebugRW[2] = IniParams[102].xyzw;
    DebugRW[3] = IniParams[103].xyzw;
}
