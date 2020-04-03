import UIKit

final class InAppViewCoordinator {
  static var inAppView: InAppViewController? {
    return R.storyboard.main.inAppViewController()
  }
  
  class func presentInAppView(in viewController: UIViewController, animated: Bool = true) {
    guard let inAppViewController = inAppView else {
      return
    }
    let viewModel = InAppViewModel()
    let tableManager = InAppViewTableManager()
    tableManager.delegate = viewModel
    inAppViewController.viewModel = viewModel
    inAppViewController.tableManager = tableManager
    inAppViewController.modalPresentationStyle = .fullScreen
    viewController.present(inAppViewController, animated: animated, completion: nil)
  }
  
  class func show(in navigationController: UINavigationController?, animated: Bool = true) {
    guard let inAppViewController = inAppView else {
      return
    }
    let viewModel = InAppViewModel()
    let tableManager = InAppViewTableManager()
    tableManager.delegate = viewModel
    inAppViewController.viewModel = viewModel
    inAppViewController.tableManager = tableManager
    navigationController?.pushViewController(inAppViewController, animated: animated)
  }
}
