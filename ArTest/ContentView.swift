import SwiftUI
import RealityKit
import ARKit

struct ContentView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

extension ARViewContainer.Coordinator: ARSessionDelegate {
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        // 当新的平面被检测到时执行
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                print("Detected a plane: \(planeAnchor)")
                
                // 可以在这里更新 UI 或做其他反馈
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 配置 AR 会话
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal] // 启用水平面检测
        arView.session.run(configuration)

        arView.session.delegate = context.coordinator
        
        // 创建一个立方体模型
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
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
    
    // 创建一个 coordinator 来管理 AR 会话和触摸事件
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    class Coordinator: NSObject {
        
        // 处理触摸点击事件
        @objc func handleTap(_ sender: UITapGestureRecognizer) {
            guard let arView = sender.view as? ARView else { return }
            
            // 获取点击位置的 raycast 结果
            let tapLocation = sender.location(in: arView)
            let results = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
            
            // 调试信息：检查 raycast 是否有结果
            print("Raycast results: \(results)")
            
            // 如果有有效的 raycast 结果
            if let firstResult = results.first {
                // 创建一个新的立方体
                let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
                let material = SimpleMaterial(color: .gray, roughness: 0.15, isMetallic: true)
                let model = ModelEntity(mesh: mesh, materials: [material])
                
                // 将模型放置到触摸的位置
                let modelAnchor = AnchorEntity(world: firstResult.worldTransform)
                modelAnchor.addChild(model)
                
                // 将模型锚点添加到 AR 视图
                arView.scene.anchors.append(modelAnchor)
                
                // 调试信息：输出放置位置
                print("Placed object at: \(firstResult.worldTransform)")
            } else {
                // 如果没有 raycast 结果，打印调试信息
                print("No valid raycast result.")
            }
        }
    }
}
