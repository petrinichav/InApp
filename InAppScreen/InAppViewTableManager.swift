import UIKit

protocol InAppViewTableManagerDelegate: AnyObject {}

class InAppViewTableManager: NSObject, UITableViewDelegate, UITableViewDataSource {
  private let rows: [InAppItem] = [.logo, .description]
  private var storage: Storage = {
    return Storage()
  }()
  
  weak var delegate: InAppViewTableManagerDelegate?
  
  // MARK: - UITableViewDataSource, UITableViewDelegate
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return rows.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = rows[indexPath.row]
    switch row {
    case .logo:
      return makeLogoCell(in: tableView, at: indexPath)
      
    case .description:
      return makeOverviewCell(in: tableView, at: indexPath)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let row = rows[indexPath.row]
    switch row {
    case .description:
      if UIDevice.isIPAD {
        return storage.defferedDeeplinkInstallation ? Constants.Style.iPad.overviewLockedCellHeight : Constants.Style.iPad.overviewDefaultCellHeight
      } else {
        return storage.defferedDeeplinkInstallation ? Constants.Style.iPhone.overviewLockedCellHeight : Constants.Style.iPhone.overviewDefaultCellHeight
      }
      
    default:
      return UITableView.automaticDimension
    }
  }
}

// MARK: - Private - Cell maker
private extension InAppViewTableManager {
  func makeLogoCell(in tableView: UITableView, at indexPath: IndexPath) -> ImageCell {
    let cell = tableView.dequeueReusableCellWithRegistration(type: ImageCell.self, indexPath: indexPath)
    cell.mainImageView.image = R.image.darkBigKeyboard()
    return cell
  }
  
  func makeOverviewCell(in tableView: UITableView, at indexPath: IndexPath) -> OverviewCell {
    let cell = tableView.dequeueReusableCellWithRegistration(type: OverviewCell.self, indexPath: indexPath)
    cell.delegate = self
    return cell
  }
}

// MARK: - Overview cell deleagte
extension InAppViewTableManager: OverviewCellDelegate {
  func didSelectOverview(row: OverviewRow) {}
}
