//
//  ContentView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

enum ExampleList: CaseIterable, Identifiable {
    case headphoneManager
    case storeKitSample
    case signInWithAppleSample
    case supabaseSample
    #if os(macOS)
        case imageTranslate
    #elseif os(iOS)
        case dualSlider
        case realityViewDemo
        case wifiAwareSample
        case alarmkitSample
    #endif
    case heatMap

    var id: Self { self }

    var display: String {
        switch self {
        case .headphoneManager:
            String(localized: "Headphone Manager")
        case .storeKitSample:
            String(localized: "StoreKit Sample")
        case .signInWithAppleSample:
            String(localized: "SignInWithApple Sample")
        case .supabaseSample:
            String(localized: "Supabase Sample")
        #if os(macOS)
            case .imageTranslate:
                String(localized: "Image Translate")
        #endif
        case .dualSlider:
            String(localized: "DualSlider")
        case .realityViewDemo:
            String(localized: "Reality View Sample")
        case .wifiAwareSample:
            String(localized: "Wi-Fi Aware Sample")
        case .alarmkitSample:
            String(localized: "AlarmKit Sample")
        case .heatMap:
            String(localized: "HeatMap")
        }
    }

    @ViewBuilder
    var itemView: some View {
        switch self {
        case .headphoneManager:
            HeadphoneManagerView()
        case .storeKitSample:
            StoreKitSampleView()
        case .signInWithAppleSample:
            SignInWithAppleSampleView()
        case .supabaseSample:
            SupabaseSampleView()
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
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    ContentView()
}
