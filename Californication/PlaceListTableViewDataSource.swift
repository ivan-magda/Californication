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
import HCSStarRatingView
import AlamofireImage

// MARK: Types

private enum PlaceListIdentifiers: String {
    case placeCell = "PlaceCell"
}

private enum DataSourceState {
    case Empty, Default
}

// MARK: - PlaceListTableViewDataSource: NSObject

final class PlaceListTableViewDataSource: NSObject {
 
    // MARK: Properties
    
    var places: [Place]?
    
    private var dataSourceState = DataSourceState.Default
    
    // MARK: Public Methods
    
    func placeForIndexPath(indexPath: NSIndexPath) -> Place? {
        return places?[indexPath.row]
    }
    
}

// MARK: - PlaceListTableViewDataSource: UITableViewDataSource -

extension PlaceListTableViewDataSource: UITableViewDataSource {
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let isEmpty = (places == nil)
        
        dataSourceState = isEmpty ? .Empty : .Default
        configureTableView(tableView)
        
        return isEmpty ? 0 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PlaceListIdentifiers.placeCell.rawValue) as! PlaceTableViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    // MARK: Helpers
    
    private func configureTableView(tableView: UITableView) {
        switch dataSourceState {
        case .Default:
            tableView.backgroundView = nil
            tableView.separatorStyle = .SingleLine
        case .Empty:
            let messageLabel = UILabel(frame: CGRect(origin: CGPointZero, size: tableView.bounds.size))
            messageLabel.text = "No data is currently available. Please pull down to refresh."
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.font = UIFont.boldSystemFontOfSize(28)
            messageLabel.textColor = .lightGrayColor()
            messageLabel.sizeToFit()
            
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = .None
        }
    }
    
    private func configureCell(cell: PlaceTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let place = placeForIndexPath(indexPath)!
        
        cell.placeTitleLabel.text = place.name
        cell.placeSummaryLabel.text = place.summary
        cell.placeRatingView.value = CGFloat(place.rating)
        
        weak var weakCell = cell
        ImageDownloadManager.sharedInstance.imageForURL(place.image.thumbnailURL) { (image, error) in
            guard error == nil else { return print("Failed to load thumbnail: \(error!.localizedDescription)") }
            weakCell?.placeImageView.image = image
        }
    }
    
}
