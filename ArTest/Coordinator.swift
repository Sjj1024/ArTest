import UIKit
import RealityKit
import ARKit

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


extension Coordinator: ARSessionDelegate {
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
