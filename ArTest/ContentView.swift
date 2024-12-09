import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置 AR 会话，启用平面检测
        let configuration = ARWorldTrackingConfiguration()
        // 启用水平面检测
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)
        
        // 创建一个立方体模型
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: false)
        let model = ModelEntity(mesh: mesh, materials: [material])
        
        // 创建一个水平面锚点
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)
        
        // 将锚点添加到场景中
        arView.scene.anchors.append(anchor)

        // 添加触摸事件识别器
        let tapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}
