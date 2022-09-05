import Metal
import MetalKit
import simd

class TriangleData {
    static let indices: [UInt16] = [0, 1, 2]
    static let positions: [simd_float3] = [.init(-1, -1, 0), .init(1, -1, 0), .init(0, 1, 0)];
    static let colors: [simd_float3] = [.init(0, 1, 0), .init(0, 0, 1), .init(1, 0, 0)];
}

class Renderer: NSObject, MTKViewDelegate {
    
    public let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pipelineState: MTLRenderPipelineState
    
    var vertexDescriptor = MTLVertexDescriptor()
    var indexBuffer: MTLBuffer!
    var positionBuffer: MTLBuffer!
    var colorBuffer: MTLBuffer!
    
    init(metalKitView: MTKView) {
        device = metalKitView.device!
        commandQueue = device.makeCommandQueue()!
        
        metalKitView.colorPixelFormat = MTLPixelFormat.bgra8Unorm_srgb
        
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.layouts[0].stride = MemoryLayout<simd_float3>.stride
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = 0
        vertexDescriptor.attributes[1].bufferIndex = 1
        vertexDescriptor.layouts[1].stride = MemoryLayout<simd_float3>.stride
        
        // Get our library that contains the compiled shader functions
        let library = device.makeDefaultLibrary()!
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "fragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        // Just set this to be the same as the metal view pixel format. They need to be the same.
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalKitView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            fatalError("Unable to make the render pipeline state: \(error)")
        }
        
        indexBuffer = device.makeBuffer(
            bytes: TriangleData.indices,
            length: MemoryLayout<UInt16>.stride * TriangleData.indices.count,
            options: .cpuCacheModeWriteCombined)
        
        positionBuffer = device.makeBuffer(
            bytes: TriangleData.positions,
            length: MemoryLayout<simd_float3>.stride * TriangleData.positions.count,
            options: .cpuCacheModeWriteCombined)
        
        colorBuffer = device.makeBuffer(
            bytes: TriangleData.colors,
            length: MemoryLayout<simd_float3>.stride * TriangleData.colors.count,
            options: .cpuCacheModeWriteCombined)
        
        super.init()
    }
    
    func draw(in view: MTKView) {
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: view.currentRenderPassDescriptor!)!
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(positionBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, index: 1)
        
        renderEncoder.drawIndexedPrimitives(type: .triangle,
                                            indexCount: TriangleData.indices.count,
                                            indexType: .uint16,
                                            indexBuffer: indexBuffer,
                                            indexBufferOffset: 0)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
}
