//
//  ContentView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

enum ExampleList: String, CaseIterable, Identifiable {
    case headphoneManager = "Headphone Manager"
    #if os(macOS)
        case imageTranslate = "Image Translate"
    #elseif os(iOS)
        case dualSlider = "DualSlider"
        case realityViewDemo = "Reality View Sample"
        case wifiAwareSample = "Wi-Fi Aware Sample"
        case alarmkitSample = "AlarmKit Sample"
    #endif
    case heatMap

    var id: Self { self }

    var display: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: self.rawValue)
    }

    @ViewBuilder
    var itemView: some View {
        switch self {
        case .headphoneManager:
            HeadphoneManagerView()
        #if os(macOS)
            case .imageTranslate:
                ImageTranslateView()
        #elseif os(iOS)
            case .dualSlider:
                DualSliderDemoView()
            case .realityViewDemo:
                RealityViewDemo()
            case .wifiAwareSample:
                WiFiAwareSampleView()
            case .alarmkitSample:
                AlarmKitSampleView()
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
