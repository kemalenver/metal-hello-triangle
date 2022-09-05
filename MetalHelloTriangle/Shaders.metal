#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

// Struct that represents an incoming vertex. attribute(x) is set from the vertex descriptor
// in the renderer code. It maps that value from there to the position attribute here.
struct Vertex {
    float3 position [[attribute(0)]];
    float3 color [[attribute(1)]];
};

// Struct that represents an outgoing vertex after processing. [[poisition]] tells the compiler to use that the
// attribute is used to store the position of the vertex - which is necessary for other parts of the pipeline.
struct VertexOut {
    float4 position [[position]];
    float3 color;
};

// Basic Vertex Shader
// This takes a vertex struct as the 'in' stage, and returns a vertex out struct.
vertex VertexOut vertexShader(Vertex in [[stage_in]]) {
    
    VertexOut out;
    out.position = float4(in.position, 1.0);
    out.color = in.color;
    
    return out;
}

// Basic Fragment Shader
// Takes the vertex out struct that was returned from the vertex processing stage.
// Returns the value of the color from that stage. Colours inbetween are interpolated for the partcilular fragment.
fragment float4 fragmentShader(VertexOut in [[stage_in]]) {
    // returns output 'as is' from the rasteriser
    return float4(in.color, 1.0);
}
