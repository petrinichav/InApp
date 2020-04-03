import Foundation
import UIKit

class InAppViewModel {
  // MARK: - Private
  private let purchaseService = PurchaseService.shared
  private let storage = Storage()
  private var subscriptionProduct: Product? {
    return self.purchaseService.product(with: PurchaseProduct.weeklySubscriptionV2.rawValue)
  }
  private lazy var defferedDeeplinkLaunch: Bool = {
    let value = storage.defferedDeeplinkInstallation
    storage.defferedDeeplinkInstallation = false
    return value
  }()
  
  // MARK: - Init
  init() {
    performSubscription()
    
    if defferedDeeplinkLaunch {
      buySubscription()
    }
  }
  
  // MARK: - Flow
  var showMessage: ShowMessage?
  var purchaseFinished: PurchaseFinished?
  var updatePurchaseDetails: PurchaseFinished?
  var close: PurchaseFinished?
  var keyboardIsExisted: Bool {
    return storage.keyboardInstalled
  }
  var isPremium: Bool {
    return storage.isPremium
  }
  var allowExit: Bool {
    return !defferedDeeplinkLaunch
  }
  
  var price: String? {
    guard !defferedDeeplinkLaunch else {
      return nil
    }
    guard let product = subscriptionProduct else {
      return nil
    }
    return Constants.PurchaseStyle.price + product.priceLabel(currencyStyle: .symbol)
  }
  
  func restoreSubscription() {
    purchaseService.restore { [weak self] result in
      self?.storage.isPremium = result
      
      guard result else {
        self?.showMessage?(Constants.Messages.restoreFail)
        return
      }
      
      self?.purchaseFinished?()
    }
  }
  
  func buySubscription() {
    purchaseService.buyWeeklySubscription { [weak self] result in
      self?.storage.isPremium = result
      
      guard result else {
        self?.showMessage?(Constants.Messages.purchaseFail)
        return
      }
      
      self?.purchaseFinished?()
    }
  }
  
  func openTermsOfUse() {
    guard let url = URL.termsOfUseURL else {
      return
    }
    openURL(url)
  }
  
  func openPolicy() {
    guard let url = URL.policyURL else {
      return
    }
    openURL(url)
  }
}

// MARK: - Private - Open url
private extension InAppViewModel {
  func openURL(_ url: URL) {
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

// MARK: - InAppViewTableManagerDelegate
extension InAppViewModel: InAppViewTableManagerDelegate {}

// MARK: - Private - Perform Subscription
private extension InAppViewModel {
  func performSubscription() {
    guard subscriptionProduct == nil else {
      return
    }
    
    Alerts.showLoading()
    purchaseService.fetchAllPurchases { [weak self] result in
      Alerts.dismissLoading()
      self?.updatePurchaseDetails?()
    }
  }
}
