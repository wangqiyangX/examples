//
//  ContentView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

enum ExampleList: String, CaseIterable, Identifiable {
    #if os(macOS)
        case imageTranslate
    #elseif os(iOS)
        case dualSlider
        case headphoneManager
    #endif
    case heatMap

    var id: Self { self }

    var display: String {
        switch self {
        #if os(macOS)
            case .imageTranslate:
                "Image Translate"
        #elseif os(iOS)
            case .dualSlider:
                "DualSlider"
            case .headphoneManager:
                "Headphone Manager"
        #endif
        case .heatMap:
            "HeatMap"
        }
    }

    @ViewBuilder
    var itemView: some View {
        switch self {
        #if os(macOS)
            case .imageTranslate:
                ImageTranslateView()
        #elseif os(iOS)
            case .dualSlider:
                DualSliderDemoView()
            case .headphoneManager:
                HeadphoneManagerView()
        #endif
        case .heatMap:
            HeatMapDemoView()
        }
    }
}

struct ContentView: View {
    @State private var selectedExample: ExampleList?
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedExample) {
                ForEach(ExampleList.allCases) { example in
                    Text(example.display)
                }
            }
            .navigationTitle("Examples")
        } detail: {
            if let selectedExample {
                selectedExample.itemView
                    .navigationTitle(selectedExample.display)
            }
        }
    }
}

#Preview {
    ContentView()
}
