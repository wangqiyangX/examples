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
        ProductID.consumableLatte.rawValue,
        ProductID.consumablePourover.rawValue,
    ]
}

@MainActor
@Observable
final class StoreKitSampleViewModel {
    private let consumableAmericanoCountKey =
        "com.wangqiyang.examples.consumable_americano count"
    private let consumableLatteCountKey =
        "com.wangqiyang.examples.consumable_latte count"
    private let consumablePouroverKey =
        "com.wangqiyang.examples.consumable_pour_over count"

    public var consumableAmericanoCount: Int {
        willSet {
            UserDefaults.standard.set(
                newValue,
                forKey: consumableAmericanoCountKey
            )
        }
    }
    public var consumableLatteCount: Int {
        willSet {
            UserDefaults.standard.set(newValue, forKey: consumableLatteCountKey)
        }
    }
    public var consumablePouroverCount: Int {
        willSet {
            UserDefaults.standard.set(newValue, forKey: consumablePouroverKey)
        }
    }
    public var activeSubscription = ""

    init() {
        self.consumableAmericanoCount = UserDefaults.standard.integer(
            forKey: consumableAmericanoCountKey
        )
        self.consumableLatteCount = UserDefaults.standard.integer(
            forKey: consumableLatteCountKey
        )
        self.consumablePouroverCount = UserDefaults.standard.integer(
            forKey: consumablePouroverKey
        )

        Task(priority: .background) {
            // Finish any unfinished transactions -- for example, if the app was terminated before finishing a transaction.
            for await verificationResult in Transaction.unfinished {
                await handle(updatedTransaction: verificationResult)
            }

            // Fetch current entitlements for all product types except consumables.
            for await verificationResult in Transaction.currentEntitlements {
                await handle(updatedTransaction: verificationResult)
            }
        }
        Task(priority: .background) {
            for await verificationResult in Transaction.updates {
                await handle(updatedTransaction: verificationResult)
            }
        }
    }

    private func handle(
        updatedTransaction verificationResult: VerificationResult<
            StoreKit.Transaction
        >
    ) async {
        guard case .verified(let transaction) = verificationResult else {
            return
        }
        if transaction.revocationDate != nil {
            guard let productID = ProductID(rawValue: transaction.productID)
            else {
                print("Unexpected product: \(transaction.productID).")
                return
            }
            switch productID {
            case .consumableAmericano:
                consumableAmericanoCount -= 1
            case .consumableLatte:
                consumableLatteCount -= 1
            case .consumablePourover:
                consumablePouroverCount -= 1
            case .subscriptionMonthly, .subscriptionYearly:
                activeSubscription = ""
            }
            await transaction.finish()
            return
        } else if let expirationDate = transaction.expirationDate,
            expirationDate < Date()
        {
            activeSubscription = ""
            return
        } else {
            guard let productID = ProductID(rawValue: transaction.productID)
            else {
                print("Unexpected product: \(transaction.productID).")
                return
            }
            print(
                "transaction ID \(transaction.id), product ID \(transaction.productID)"
            )
            switch productID {
            case .consumableAmericano:
                consumableAmericanoCount += 1
            case .consumableLatte:
                consumableLatteCount += 1
            case .consumablePourover:
                consumablePouroverCount += 1
            case .subscriptionMonthly, .subscriptionYearly:
                activeSubscription = transaction.productID
            }
            await transaction.finish()
            return
        }
    }
}

struct StoreKitSampleView: View {
    let subscriptionsGroupID: String = "C3813BBD"

    @State private var showProductsView: Bool = false
    @State private var showSubscriptionStoreView: Bool = false
    @State private var viewModel = StoreKitSampleViewModel()

    var body: some View {
        List {
            Section {
                LabeledContent(
                    "Americano",
                    value: viewModel.consumableAmericanoCount,
                    format: .number
                )
                LabeledContent(
                    "Latte",
                    value: viewModel.consumableLatteCount,
                    format: .number
                )
                LabeledContent(
                    "Pour-over",
                    value: viewModel.consumablePouroverCount,
                    format: .number
                )
                DisclosureGroup {
                    ProductView(id: ProductID.consumableAmericano.rawValue)
                    ProductView(id: ProductID.consumableLatte.rawValue)
                    ProductView(id: ProductID.consumablePourover.rawValue)
                } label: {
                    Label("Buy Me a Coffee", systemImage: "cup.and.saucer")
                }
                .productViewStyle(.compact)
            }
            
            Section {
                LabeledContent("Subscription", value: viewModel.activeSubscription)
                Button("Subscriptions") {
                    withAnimation {
                        showSubscriptionStoreView.toggle()
                    }
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
