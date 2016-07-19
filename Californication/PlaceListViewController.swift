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

// MARK: PlaceListViewController: UIViewController

class PlaceListViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var placeDirector: PlaceDirectorFacade!
    private let tableViewDataSource = PlaceListTableViewDataSource()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        loadPlaces()
    }
    
    // MARK: Private
    
    private func setup() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
    }
    
    private func loadPlaces() {
        showLoadingHud()
        
        placeDirector.allPlaces({ [weak self] places in
            self?.hideLoadingHud()
            self?.tableViewDataSource.places = places.sort { $0.name < $1.name }
            self?.tableView.reloadData()
        }) { [weak self] error in
            guard error == nil else {
                self?.hideLoadingHud()
                self?.presentAlertWithTitle("Error", message: error!.localizedDescription)
                return
            }
        }
    }
    
}

// MARK: - PlaceListViewController (UI Functions) -

extension PlaceListViewController {
    
    private func showLoadingHud() {
        let progressHud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHud.labelText = "Loading"
    }
    
    private func hideLoadingHud() {
        MBProgressHUD.hideAllHUDsForView(view, animated: true)
    }
    
}

// MARK: - PlaceListViewController: UITableViewDelegate -

extension PlaceListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
