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

// MARK: Constants

private let kTableHeaderHeight: CGFloat = 300.0

// MARK: - PlaceDetailsViewController: UIViewController -

class PlaceDetailsViewController: UIViewController {
  
  // MARK: Properties
  
  @IBOutlet weak var tableView: UITableView!
  fileprivate var headerView: PlaceImageHeaderView!
  
  var place: Place!
  fileprivate var tableViewDataSource: PlaceDetailsTableViewDataSource!
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    assert(place != nil)
    setup()
  }
  
  // MARK: Setup
  
  fileprivate func setup() {
    configureTableView()
    configureUI()
  }
  
  fileprivate func configureTableView() {
    tableViewDataSource = PlaceDetailsTableViewDataSource(place: place)
    tableView.dataSource = tableViewDataSource
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 44.0
    
    headerView = tableView.tableHeaderView as! PlaceImageHeaderView
    headerView.headerHeight = kTableHeaderHeight
    headerView.delegate = self
    tableView.tableHeaderView = nil
    tableView.addSubview(headerView)
    
    (tableView as UIScrollView).delegate = self
    tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
    tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
    headerView.layoutSubviewsWithContentOffset(tableView.contentOffset)
  }
  
  fileprivate func configureUI() {
    let showCloseButton = navigationController == nil
    headerView.closeButton.isEnabled = showCloseButton
    headerView.closeButton.isHidden = !showCloseButton
    
    headerView.activityIndicator.startAnimating()
    ImageDownloadManager.sharedInstance.imageForURL(place.image.mediumURL) { [weak self] (image, error) in
      self?.headerView.activityIndicator.stopAnimating()
      guard error == nil else {
        self?.presentAlertWithTitle("Failed to load image", message: error!.localizedDescription)
        return
      }
      self?.headerView.imageView.image = image
    }
  }
  
}

// MARK: - PlaceDetailsViewController: UIScrollViewDelegate -

extension PlaceDetailsViewController: UIScrollViewDelegate {
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    headerView.layoutSubviewsWithContentOffset(scrollView.contentOffset)
  }
  
}

// MARK: - PlaceDetailsViewController: PlaceImageHeaderViewDelegate -

extension PlaceDetailsViewController: PlaceImageHeaderViewDelegate {
  
  func placeImageHeaderViewCloseDidPressed(_ view: PlaceImageHeaderView) {
    dismiss(animated: true, completion: nil)
  }
  
}
