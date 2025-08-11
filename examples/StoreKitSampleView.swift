//
//  StoreKitSampleView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/11.
//

import StoreKit
import SwiftUI

enum ProductID: String {
    case consumableAmericano = "consumable_americano"
    case consumableLatte = "consumable_latte"
    case consumablePourover = "consumable_pour_over"

    case subscriptionMonthly = "subscription_monthly"
    case subscriptionYearly = "subscription_yearly"
}

extension ProductID {
    static let subscriptions = [
        ProductID.subscriptionMonthly.rawValue,
        ProductID.subscriptionYearly.rawValue,
    ]
    static let consumables = [
        ProductID.consumableAmericano.rawValue,
        ProductID.consumablePourover.rawValue,
        ProductID.consumableLatte.rawValue,
    ]
}

@MainActor
@Observable
final class StoreKitSampleViewModel {

}

struct StoreKitSampleView: View {
    let subscriptionsGroupID: String = "C3813BBD"

    @State private var showProductsView: Bool = false
    @State private var showSubscriptionStoreView: Bool = false

    var body: some View {
        List {
            Button("Consumable") {
                withAnimation {
                    showProductsView.toggle()
                }
            }
            Button("Subscriptions") {
                withAnimation {
                    showSubscriptionStoreView.toggle()
                }
            }
        }
        .sheet(isPresented: $showSubscriptionStoreView) {
            // SubscriptionOfferView(id: ProductID.subscriptionMonthly.rawValue)
            SubscriptionStoreView(groupID: "C3813BBD")
            //                .subscriptionStoreControlStyle(.picker)
        }
        .sheet(isPresented: $showProductsView) {
            StoreView(ids: ProductID.consumables)
        }
    }
}

#Preview {
    StoreKitSampleView()
}
