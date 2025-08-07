//
//  GenerativeView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import FoundationModels
import SwiftUI

struct GenerativeView: View {
    private var model = SystemLanguageModel.default

    var body: some View {
        switch model.availability {
        case .available:
            // Show your intelligence UI.
            Text("available")
        case .unavailable(.deviceNotEligible):
            // Show an alternative UI.
            Text("unavailable(.deviceNotEligible)")
        case .unavailable(.appleIntelligenceNotEnabled):
            // Ask the person to turn on Apple Intelligence.
            Text("unavailable(.appleIntelligenceNotEnabled)")
        case .unavailable(.modelNotReady):
            // The model isn't ready because it's downloading or because of other system reasons.
            Text("unavailable(.modelNotReady)")
        case .unavailable:
            // The model is unavailable for an unknown reason.
            Text("unavailable(let other)")
        }
    }
}

#Preview {
    GenerativeView()
}
