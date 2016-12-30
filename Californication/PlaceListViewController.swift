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

private let kSortingTypeIdentifier = "sortingType"

// MARK: Types

private enum SortingType: Int {
  case name, rating
}

// MARK: - PlaceListViewController: UIViewController

class PlaceListViewController: UIViewController {
  
  // MARK: Outlets
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortingButton: UIBarButtonItem!
  
  // MARK: Properties
  
  var didSelect: (Place) -> () = { _ in }
  var placeDirector: PlaceDirectorFacade!
  
  fileprivate var sortingType: SortingType {
    get {
      let defaults = UserDefaults.standard
      let value = defaults.integer(forKey: kSortingTypeIdentifier)
      return SortingType(rawValue: value) ?? .rating
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
    func didSelectSortingType(_ type: SortingType) {
      guard type != sortingType else { return }
      sortingType = type
      reloadData()
    }
    
    let actionController = UIAlertController(title: "Sorting", message: nil, preferredStyle: .actionSheet)
    actionController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    actionController.addAction(UIAlertAction(title: "By name", style: .default, handler: { action in
      didSelectSortingType(.name)
    }))
    actionController.addAction(UIAlertAction(title: "By rating", style: .default, handler: { action in
      didSelectSortingType(.rating)
    }))
    
    present(actionController, animated: true, completion: nil)
  }
  
  // MARK: Configure
  
  fileprivate func setup() {
    configureTableView()
    
    if let places = placeDirector.persistedPlaces() {
      updateWithNewData(places)
    }
  }
  
  fileprivate func configureTableView() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 120
    tableView.dataSource = tableViewDataSource
    tableView.delegate = self
    
    tableView.addSubview(refreshControl)
    refreshControl.addTarget(self, action: #selector(loadPlaces), for: .valueChanged)
  }
  
  // MARK: Data
  
  func loadPlaces() {
    startLoading()
    
    placeDirector.allPlaces({ [weak self] places in
      self?.didStopLoading()
      self?.placeDirector.savePlaces(places)
      self?.updateWithNewData(places)
    }) { [weak self] error in
      guard error == nil else {
        self?.didStopLoading()
        self?.presentAlertWithTitle("Error", message: error!.localizedDescription)
        return
      }
    }
  }
  
  fileprivate func updateWithNewData(_ places: [Place]) {
    tableViewDataSource.places = places
    reloadData()
  }
  
  fileprivate func reloadData() {
    sortPlaces()
    tableView.reloadData()
  }
  
  fileprivate func sortPlaces() {
    func sortByName() -> [Place] {
      return tableViewDataSource.places!.sorted { $0.name < $1.name }
    }
    
    func sortByRating() -> [Place] {
      return sortByName().sorted { $0.rating > $1.rating }
    }
    
    guard let _ = tableViewDataSource.places else { return }
    
    switch sortingType {
    case .name:
      tableViewDataSource.places = sortByName()
    case .rating:
      tableViewDataSource.places = sortByRating()
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
  
  fileprivate func didStopLoading() {
    MBProgressHUD.hide(for: view, animated: true)
    refreshControl.endRefreshing()
    
    sortingButton.isEnabled = true
  }
  
}

// MARK: - PlaceListViewController: UITableViewDelegate -

extension PlaceListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let selectedPlace = tableViewDataSource.placeForIndexPath(indexPath) else {
      return
    }
    
    didSelect(selectedPlace)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
