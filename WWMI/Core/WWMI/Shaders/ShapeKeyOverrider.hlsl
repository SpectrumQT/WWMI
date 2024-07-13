// Shader: WWMI Shape Key Overrider
// Version: 1.0
// Creator: SpectumQT
// Comment: Builds custom CB that controls Shape Key CS chain:
// * Filters out objects with mismatching shape key offsets checksum (THREAD_GROUP_COUNT_Y alone may not be enough)
// * Overrides default shape key offsets with ones from custom buffer (exported from Blender)
// * Overrides default shape key values with ones from custom buffer (modified via ini WWMI calls)

Texture1D<float4> IniParams : register(t120);

#define ShapeKeyCheckSum IniParams[0].x

// CB0 structure (len == 66):
// 1. 32 uint4 shapekey offsets (static, total 128)
// 2. 32 unorm4 shapekey values (dynamic, total 128)
// 3. 2 uint4 CS logic vars (dynamic)
cbuffer cb0 : register(b0)
{
  uint4 cb0[66];
}

// Custom shape key offsets exported from Blender
Buffer<uint4> CustomShapeKeys : register(t33);

// Custom shape key values configured via ini WWMI calls
RWBuffer<float4> CustomShapeKeyValuesRW : register(u5);

// Output: custom CB constructed based on default CB0 and configured overrides
RWBuffer<uint4> ShapeKeysControlCBRW : register(u6);

// RWBuffer<float4> DebugRW : register(u7);


#ifdef COMPUTE_SHADER


[numthreads(64,1,1)]
void main(uint3 ThreadId : SV_DispatchThreadID)
{
    uint idx = ThreadId.x;
    
    // Check if first 4 shape key offsets of CB0 match dumped offsets
    // In case of mismatch we'll just let default data pass through unmodified
    uint is_custom_mesh = false;
    if (cb0[0].x + cb0[0].y + cb0[0].z + cb0[0].w == uint(ShapeKeyCheckSum)) {
        is_custom_mesh = true;
    }

    // Copy logic vars (64 and 65 indices) from CB0 to ShapeKeysControlCBRW
    if (ThreadId.x < 2) {
        ShapeKeysControlCBRW[64+ThreadId.x] = cb0[64+ThreadId.x];
    }

    // Copy current shape key values from CB0 to let dynamic data passthrough
    uint4 default_values = cb0[ThreadId.x];

    // Override current shape key offsets with custom ones if current CB0 matches dumped CB0
    if (is_custom_mesh && ThreadId.x < 32) {
        // Copy custom shape key offsets if current CB0 matches dumped CB0
        default_values = CustomShapeKeys[ThreadId.x];
    } 

    // DebugRW[ThreadId.x] = CustomShapeKeys[ThreadId.x];

    // Override current shape key values with custom ones if current CB0 matches dumped CB0
    if (is_custom_mesh && ThreadId.x >= 32) {
        // Copy custom shape key values to override defaults
        float4 custom_values = CustomShapeKeyValuesRW[ThreadId.x-32];
        // Override default values with non-zero custom values (zero is encoded as 1.0)
        // 1. If 'shape_key_value == 0.0', default shape key value won't be overriden
        // 2. If 'shape_key_value == 1.0', default shape key will be overrided with zero (0.0)
        // 3. If 'shape_key_value > 1.0', default shape key will be overrided with 'shape_key_value - 1.0'
        default_values.x = custom_values.x >= 1.0 ? asuint(custom_values.x - 1.0) : default_values.x;
        default_values.y = custom_values.y >= 1.0 ? asuint(custom_values.y - 1.0) : default_values.y;
        default_values.z = custom_values.z >= 1.0 ? asuint(custom_values.z - 1.0) : default_values.z;
        default_values.w = custom_values.w >= 1.0 ? asuint(custom_values.w - 1.0) : default_values.w;
    }

    ShapeKeysControlCBRW[ThreadId.x] = default_values;
    
    // DebugRW[ThreadId.x] = ShapeKeysControlCBRW[ThreadId.x];
}

#endif