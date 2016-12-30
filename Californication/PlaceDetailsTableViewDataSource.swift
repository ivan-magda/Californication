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

// MARK: Types

private enum SectionType {
  case title, detail
}

private enum Item {
  case title, types, summary, description, address, phoneNumber, website, rating, priceLevel
}

private struct Section {
  var type: SectionType
  var items: [Item]
}

// MARK: - PlaceDetailsTableViewDataSource: NSObject

final class PlaceDetailsTableViewDataSource: NSObject {
  
  // MARK: Properties
  
  var place: Place!
  fileprivate var sections = [Section]()
  
  // MARK: Init
  
  override init() {
    super.init()
    buildTableStructure()
  }
  
  convenience init(place: Place) {
    self.init()
    self.place = place
  }
  
  // MARK: Private
  
  fileprivate func buildTableStructure() {
    sections = [
      Section(type: .title, items: [.title]),
      Section(type: .detail, items: [.types, .summary, .description, .address, .phoneNumber,
                                     .website, .rating, .priceLevel]
      )
    ]
  }
  
}

// MARK: - PlaceDetailsTableViewDataSource: UITableViewDataSource -

extension PlaceDetailsTableViewDataSource: UITableViewDataSource {
  
  // MARK: UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = sections[indexPath.section]
    
    switch section.type {
    case .title:
      let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.reuseIdentifier) as! TitleTableViewCell
      cell.titleLabel.text = place.name
      
      return cell
    case .detail:
      switch section.items[indexPath.row] {
      case .rating:
        let cell = tableView.dequeueReusableCell(withIdentifier: RatingTableViewCell.reuseIdentifier) as! RatingTableViewCell
        cell.starRatingView.value = CGFloat(place.rating)
        
        return cell
      default:
        let cell = tableView.dequeueReusableCell(withIdentifier: PlaceDetailTableViewCell.reuseIdentifier) as! PlaceDetailTableViewCell
        configureDetailCell(cell, atIndexPath: indexPath)
        
        return cell
      }
    }
  }
  
  // MARK: Helpers
  
  fileprivate func configureDetailCell(_ cell: PlaceDetailTableViewCell, atIndexPath indexPath: IndexPath) {
    func clearLabelText() {
      cell.placeTitleLabel.text = nil
      cell.placeDetailLabel.text = nil
    }
    
    switch sections[indexPath.section].items[indexPath.row] {
    case .types:
      cell.placeTitleLabel.text = "Types"
      cell.placeDetailLabel.text = place.types.joined(separator: ", ")
    case .summary:
      cell.placeTitleLabel.text = "Summary"
      cell.placeDetailLabel.text = place.summary
    case .description:
      cell.placeTitleLabel.text = "Description"
      cell.placeDetailLabel.text = place.detailDescription
    case .address:
      if let address = place.formattedAddress {
        cell.placeTitleLabel.text = "Address"
        cell.placeDetailLabel.text = address
      } else {
        clearLabelText()
      }
    case .phoneNumber:
      if let phoneNumber = place.phoneNumber {
        cell.placeTitleLabel.text = "Phone number"
        cell.placeDetailLabel.text = phoneNumber
      } else {
        clearLabelText()
      }
    case .website:
      if let website = place.website?.host {
        cell.placeTitleLabel.text = "Website"
        cell.placeDetailLabel.text = website
      } else {
        clearLabelText()
      }
    case .priceLevel:
      if let priceLevel = place.priceLevel.title() {
        cell.placeTitleLabel.text = "Price level"
        cell.placeDetailLabel.text = priceLevel
      } else {
        clearLabelText()
      }
    default:
      break
    }
  }
  
}
