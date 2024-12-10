import ARKit
import RealityKit
import SwiftUI

struct ContentView: View {
    let modelName = ["biplane", "drummertoy", "pancakes", "pegasus", "retrotv", "stratocaster", "toycar", "tulip"]
    var modelMap: [String: ModelEntity] = [:]

    @State private var curModel: ModelEntity

    init() {
        print("init app")
        for model in modelName {
            let modelEntry = try! ModelEntity.loadModel(named: "\(model).usdz")
            self.modelMap[model] = modelEntry
        }
        self.curModel = self.modelMap[self.modelName.first!]!
    }

    var body: some View {
        VStack {
            ARViewContainer(curModel: $curModel)
            ScrollView(.horizontal) {
                HStack(content: {
                    ForEach(modelName, id: \.self) {
                        model in
                        Image(model).resizable().frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/).onTapGesture {
                            print("click model: \(model)")
                            // 更新当前模型
                            curModel = self.modelMap[model]!
                        }
                    }
                })
            }.padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var curModel: ModelEntity

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.debugOptions = .showFeaturePoints

        // 配置 AR 会话，启用平面检测
        let configuration = ARWorldTrackingConfiguration()
        // 启用水平面检测
        configuration.planeDetection = [.horizontal]
        arView.session.run(configuration)

        // 创建一个水平面锚点
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))

        // 加载usdz模型文件
        let modelEntry = curModel
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
        // 给arview添加动作识别
        arView.addGestureRecognizer(tapGestureRecognizer)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        print("update ui view")
        // 删除之前的模型
        uiView.scene.anchors.removeAll()
        // 更新模型
        let modelEntry = curModel
        modelEntry.position = [0, 0, 0]
        modelEntry.scale = [0.01, 0.01, 0.01]
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.addChild(modelEntry)
        uiView.scene.anchors.append(anchor)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}
