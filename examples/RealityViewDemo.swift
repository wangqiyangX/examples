//
//  RealityViewDemo.swift
//  examples
//
//  Created by wangqiyang on 2025/8/8.
//

import RealityKit
import SwiftUI

struct RealityViewDemo: View {
    var body: some View {
        RealityView { content in
            if let model = try? await ModelEntity(named: "mask") {
                content.add(model)
                content.cameraTarget = model
            }
        } placeholder: {
            VStack {
                ProgressView()
            }
        }
    }
}

#Preview {
    RealityViewDemo()
}
