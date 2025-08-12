//
//  StoreKitSampleView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/11.
//


/*
 使用前准备与测试说明：

 1. 启用能力
    - 在 Target > Signing & Capabilities 中添加 “In-App Purchase”。

 2. 创建 StoreKit 配置文件（用于本地测试）
    - File > New > StoreKit Configuration File，命名例如: Examples.storekit。
    - 在该 .storekit 文件中：
      • 新建 Consumable（一次性消耗型）商品，商品标识需与代码保持一致：
        - consumable_americano
        - consumable_latte
        - consumable_pour_over
      • 新建 Subscription Group（订阅组），并在组内添加订阅产品：
        - subscription_monthly
        - subscription_yearly
      • 记录订阅组的 groupID（在 .storekit 的订阅组详情中可见），并在代码中替换为你的 groupID。
        - 本示例中占位值为 "C3813BBD"。请用你的订阅组 ID 替换。
      • 可选：配置价格、本地化、促销/优惠（例如 Intro Offer）、续期周期等。

 3. 绑定 StoreKit 配置文件到运行方案（非常关键）
    - Product > Scheme > Edit Scheme… > Run > Options > StoreKit Configuration，选择刚创建的 .storekit 文件。
    - 如需在 UI Tests/Unit Tests 中也使用，可在对应的 Test 方案中同样设置。

 4. 本地测试的公钥证书（可选，仅当你在本地验证签名或自建服务端时需要）
    - 打开 .storekit 文件，菜单 Editor > Save Public Certificate。
    - 将导出的证书（.cer）加入到工程或提供给你的服务端用于验证本地测试签名。

 5. 本地运行与调试
    - 在模拟器或真机直接运行，Xcode 会使用绑定的 .storekit 文件进行本地交易。
    - 需要重置测试交易：Debug > StoreKit > Clear Transactions（或在 .storekit 文件的 … 菜单中 Reset）。
    - 可在 Xcode > Settings > Accounts > StoreKit Test Accounts 中管理本地测试账户（可选）。

 6. 沙盒测试（连接 App Store 沙盒环境，而非本地 .storekit）
    - 将 Run Scheme 中的 “StoreKit Configuration” 清空（不绑定 .storekit）。
    - 在 App Store Connect 创建 Sandbox Tester，并在设备设置 > App Store 使用该测试账号登录。
    - 确保 App Store Connect 中已创建与代码一致的产品 ID 与订阅组，并处于可测试状态。

 7. 上线与生产环境注意事项
    - Bundle Identifier 与 App Store Connect 一致。
    - 产品 ID 必须与 App Store Connect 中配置完全一致。
    - 提交包含 IAP 的构建版本，并完成税务/银行/合规相关配置与审核。

 8. 平台与版本要求
    - 本示例使用 StoreKit 2 与 SwiftUI 的内置商店视图（ProductView / StoreView / SubscriptionStoreView），
      需要 iOS 16+（或同版本的其他 Apple 平台）与 Xcode 15+。
    - 如果需要兼容更低系统版本，请使用可用性判断（@available）或提供自定义 UI 作为降级方案。

 9. 代码中需替换的示例占位
    - 将 SubscriptionStoreView(groupID: "C3813BBD") 与 subscriptionsGroupID 替换为你在
      .storekit 或 App Store Connect 中的真实订阅组 ID。
 */

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
