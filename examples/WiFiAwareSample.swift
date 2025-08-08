//
//  WiFiAwareSample.swift
//  examples
//
//  Created by wangqiyang on 2025/8/8.
//

import DeviceDiscoveryUI
import Network
import SwiftUI
import WiFiAware

//guard WACapabilities.supportedFeatures.contains(.wifiAware) else { return }

let exampleTCPServiceName = "_example-service._tcp"
let exampleUDPServiceName = "_example-service._udp"

extension WAPublishableService {
    public static var exampleTCPService: WAPublishableService {
        allServices[exampleTCPServiceName]!
    }
    public static var exampleUDPService: WAPublishableService {
        allServices[exampleUDPServiceName]!
    }
}

extension WASubscribableService {
    public static var exampleTCPService: WASubscribableService {
        allServices[exampleTCPServiceName]!
    }
    public static var exampleUDPService: WASubscribableService {
        allServices[exampleUDPServiceName]!
    }
}

extension WAAccessCategory {
    var serviceClass: NWParameters.ServiceClass {
        switch self {
        case .bestEffort: .bestEffort
        case .background: .background
        case .interactiveVideo: .interactiveVideo
        case .interactiveVoice: .interactiveVoice
        default: .bestEffort
        }
    }
}

@Observable
class WiFiAwareSampleViewModel {

}

struct WiFiAwareSampleView: View {
    @State private var viewModel: WiFiAwareSampleViewModel =
        WiFiAwareSampleViewModel()

    var body: some View {
        if WACapabilities.supportedFeatures.contains(.wifiAware) {
            List {

            }
        } else {
            ContentUnavailableView {
                Label(
                    "This device does not support Wi-Fi Aware",
                    systemImage: "exclamationmark.octagon"
                )
            }
        }
    }
}

#Preview {
    WiFiAwareSampleView()
}
