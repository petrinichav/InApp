import UIKit

class InAppViewController: BaseViewController {
  @IBOutlet private var tableView: UITableView!
  @IBOutlet private var closeButton: UIButton!
  @IBOutlet private var continueButton: ShinyButton!
  @IBOutlet private var priceLabel: UILabel!

  var tableManager: InAppViewTableManager?
  
  // MARK: - ViewModel
  var viewModel: InAppViewModel!
  
  // MARK: - Life
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    bindings()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  // MARK: - Private - Button action
  @IBAction private func onRestore(button: UIButton) {
    viewModel.restoreSubscription()
  }
  
  @IBAction private func onContinue(button: UIButton) {
    viewModel.buySubscription()
  }
  
  @IBAction private func onTermOfUser(button: UIButton) {
    viewModel.openTermsOfUse()
  }
  
  @IBAction private func onPolicy(button: UIButton) {
    viewModel.openPolicy()
  }
  
  @IBAction private func onClose(button: UIButton) {
    finish()
  }
}

// MARK: - Private - Layout
private extension InAppViewController {
  func setupLayout() {
    setupTableView()
    setupCloseButton()
    
    continueButton.startShiny()
    priceLabel.text = viewModel.price
            
    if #available(iOS 13.0, *) {
      overrideUserInterfaceStyle = .light
    }
  }
  
  func setupTableView() {
    tableView.delegate = tableManager
    tableView.dataSource = tableManager
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = UIDevice.isIPAD ? Constants.Style.iPad.defaultCellHeight : Constants.Style.iPhone.defaultCellHeight
    
    tableView.separatorStyle = .none
  }
  
  func setupCloseButton() {
    closeButton.alpha = 0
    
    guard viewModel.allowExit else {
      return
    }
    UIView.animate(withDuration: Constants.Style.defaultAnimationDuration,
                   delay: Constants.Style.animationDelay,
                   options: .showHideTransitionViews,
                   animations: {
                    self.closeButton.alpha = 1
    })
  }
}

// MARK: - Private - Next
private extension InAppViewController {
  func finish() {
    guard viewModel.allowExit else {
      return
    }
    
    if presentingViewController != nil {
      dismiss(animated: true, completion: nil)
    } else {
      if !viewModel.isPremium {
        InAppWithTrialCoordinator.show(in: navigationController)
    } else if !viewModel.keyboardIsExisted {
        InstructionViewCoordinator.show(in: navigationController)
    } else {
        EnjoyViewCoordinator.show(in: navigationController)
      }
    }
  }
}

// MARK: - Private - Bindings
private extension InAppViewController {
  func bindings() {
    viewModel.showMessage = { message in
      Alerts.showMessage(message)
    }
    
    viewModel.purchaseFinished = { [weak self] in
      DispatchQueue.main.async {
        self?.finish()
        Reviewer.requestReview()
      }
    }
    
    viewModel.updatePurchaseDetails = { [weak self] in
      self?.tableView.reloadData()
    }
    
    viewModel.close = { [weak self] in
      self?.finish()
    }
  }
}
