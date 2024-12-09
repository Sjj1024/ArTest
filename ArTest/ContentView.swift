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

        // 创建一个水平面锚点
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))

        // 加载usdz模型文件
        let modelEntry = try! ModelEntity.loadModel(named: "pancakes.usdz")
        modelEntry.position = [0, 0, 0]
        modelEntry.scale = [0.01, 0.01, 0.01]
        anchor.addChild(modelEntry)

        // 创建一个灯光
        let light = PointLight()
        light.position = [0, 1, 0]
        anchor.addChild(light)

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
