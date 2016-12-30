/**
 * Copyright (c) 2016 Ivan Magda
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MBProgressHUD

// MARK: Constants

private let kSortingTypeIdentifier = "sortType"

// MARK: Types

private enum SortType: Int {
  case name, rating
}

// MARK: - PlaceListViewController: UIViewController

final class PlaceListViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortingButton: UIBarButtonItem!
  
  // MARK: Properties
  
  var didSelect: (Place) -> () = { _ in }
  var placeDirector: PlaceDirectorFacade!
  
  private var sortType: SortType {
    get {
      let value = UserDefaults.standard.integer(forKey: kSortingTypeIdentifier)
      return SortType(rawValue: value) ?? .rating
    }
    
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: kSortingTypeIdentifier)
    }
  }
  
  fileprivate let tableViewDataSource = PlaceListTableViewDataSource()
  fileprivate let refreshControl = UIRefreshControl()
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.statusBarStyle = .lightContent
  }
  
  // MARK: Actions
  
  @IBAction func sortDidPressed(_ sender: AnyObject) {
    func sort(by type: SortType) {
      guard type != sortType else { return }
      sortType = type
      reloadData()
    }
    
    let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    actionController.addAction(UIAlertAction(title: "By name", style: .default, handler: { _ in
      sort(by: .name)
    }))
    actionController.addAction(UIAlertAction(title: "By rating", style: .default, handler: { _ in
      sort(by: .rating)
    }))
    
    present(actionController, animated: true, completion: nil)
  }
  
  // MARK: Configure
  
  private func setup() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
    refreshControl.addTarget(self, action: #selector(loadPlaces), for: .valueChanged)
    
    if let places = placeDirector.persisted() {
      update(with: places)
    }
  }
  
  // MARK: Data
  
  @objc private func loadPlaces() {
    startLoading()
    
    placeDirector.all({ [weak self] places in
      guard let strongSelf = self else { return }
      strongSelf.stopLoading()
      strongSelf.placeDirector.save(places)
      strongSelf.update(with: places)
    }) { [weak self] error in
      guard let strongSelf = self else { return }
      guard error == nil else {
        strongSelf.stopLoading()
        strongSelf.presentAlertWithTitle("Error", message: error!.localizedDescription)
        return
      }
    }
  }
  
  private func update(with newPlaces: [Place]) {
    tableViewDataSource.places = newPlaces
    reloadData()
  }
  
  private func reloadData() {
    tableViewDataSource.places = sortedPlaces()
    tableView.reloadData()
  }
  
  private func sortedPlaces() -> [Place] {
    func sortedByName() -> [Place] {
      return tableViewDataSource.places!.sorted { $0.name < $1.name }
    }
    
    func sortedByRating() -> [Place] {
      return sortedByName().sorted { $0.rating > $1.rating }
    }
    
    guard let _ = tableViewDataSource.places else { return [] }
    
    switch sortType {
    case .name:
      return sortedByName()
    case .rating:
      return sortedByRating()
    }
  }
  
}

// MARK: - PlaceListViewController (UI Functions) -

extension PlaceListViewController {
  
  fileprivate func startLoading() {
    let progressHud = MBProgressHUD.showAdded(to: view, animated: true)
    progressHud.label.text = "Loading"
    sortingButton.isEnabled = false
  }
  
  fileprivate func stopLoading() {
    MBProgressHUD.hide(for: view, animated: true)
    refreshControl.endRefreshing()
    sortingButton.isEnabled = true
  }
  
}

// MARK: - PlaceListViewController: UITableViewDelegate -

extension PlaceListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedPlace = tableViewDataSource.place(for: indexPath) else { return }
    didSelect(selectedPlace)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
