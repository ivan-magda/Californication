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

import Foundation
import CoreLocation.CLLocation
import GoogleMaps

// MARK: Types

private enum Key: String {
  case placeID
  case name
  case summary
  case detailDescription
  case phoneNumber
  case latitude
  case longitude
  case formattedAddress
  case rating
  case priceLevel
  case types
  case website
  case image
}

enum PlacePriceLevel: Int {
  case unknown = -1
  case free
  case cheap
  case medium
  case high
  case expensive
  
  func title() -> String? {
    switch self {
    case .unknown:
      return nil
    case .free:
      return "Free"
    case .cheap:
      return "$"
    case .medium:
      return "$$"
    case .high:
      return "$$$"
    case .expensive:
      return "$$$$"
    }
  }
}

// MARK: - Place: NSObject, NSCoding

class Place: NSObject, NSCoding {
  
  /** Place ID of this place. */
  let placeID: String
  
  /** Name of the place. */
  let name: String
  
  /** Short summary about the place. */
  let summary: String
  
  /** Detail description about the place. */
  let detailDescription: String
  
  /**
   * Phone number of this place, in international format, i.e. including the country code prefixed
   * with "+".  For example: "+61 2 9374 4000".
   */
  let phoneNumber: String?
  
  /** Location of the place. */
  let coordinate: CLLocationCoordinate2D
  
  /**
   * Address of the place as a simple string.
   */
  let formattedAddress: String?
  
  /**
   * Five-star rating for this place based on user reviews.
   *
   * Ratings range from 1.0 to 5.0.  0.0 means we have no rating for this place (e.g. because not
   * enough users have reviewed this place).
   */
  let rating: Float
  
  /**
   * Price level for this place, as integers from 0 to 4.
   *
   * e.g. A value of 4 means this place is "$$$$" (expensive).  A value of 0 means free (such as a
   * museum with free admission).
   */
  let priceLevel: PlacePriceLevel
  
  /// The types of this place.
  let types: [String]
  
  /** Website for this place. */
  let website: URL?
  
  /** Images of the place */
  let image: PlaceImage
  
  init(placeID: String, name: String, summary: String, detailDescription: String, phoneNumber: String?, coordinate: CLLocationCoordinate2D, formattedAddress: String?, rating: Float, priceLevel: PlacePriceLevel, types: [String], website: URL?, image: PlaceImage) {
    self.placeID = placeID
    self.name = name
    self.summary = summary
    self.detailDescription = detailDescription
    self.phoneNumber = phoneNumber
    self.coordinate = coordinate
    self.formattedAddress = formattedAddress
    self.rating = rating
    self.priceLevel = priceLevel
    self.types = types
    self.website = website
    self.image = image
    
    super.init()
  }
  
  // MARK: NSCoding
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(placeID, forKey: Key.placeID.rawValue)
    aCoder.encode(name, forKey: Key.name.rawValue)
    aCoder.encode(summary, forKey: Key.summary.rawValue)
    aCoder.encode(detailDescription, forKey: Key.detailDescription.rawValue)
    aCoder.encode(phoneNumber, forKey: Key.phoneNumber.rawValue)
    aCoder.encode(coordinate.latitude, forKey: Key.latitude.rawValue)
    aCoder.encode(coordinate.longitude, forKey: Key.longitude.rawValue)
    aCoder.encode(formattedAddress, forKey: Key.formattedAddress.rawValue)
    aCoder.encode(rating, forKey: Key.rating.rawValue)
    aCoder.encodeCInt(Int32(priceLevel.rawValue), forKey: Key.priceLevel.rawValue)
    aCoder.encode(types, forKey: Key.types.rawValue)
    aCoder.encode(website, forKey: Key.website.rawValue)
    aCoder.encode(image, forKey: Key.image.rawValue)
  }
  
  required init?(coder aDecoder: NSCoder) {
    placeID = aDecoder.decodeObject(forKey: Key.placeID.rawValue) as! String
    name = aDecoder.decodeObject(forKey: Key.name.rawValue) as! String
    summary = aDecoder.decodeObject(forKey: Key.summary.rawValue) as! String
    detailDescription = aDecoder.decodeObject(forKey: Key.detailDescription.rawValue) as! String
    phoneNumber = aDecoder.decodeObject(forKey: Key.phoneNumber.rawValue) as? String
    formattedAddress = aDecoder.decodeObject(forKey: Key.formattedAddress.rawValue) as? String
    rating = aDecoder.decodeFloat(forKey: Key.rating.rawValue)
    priceLevel = PlacePriceLevel(rawValue: Int(aDecoder.decodeCInt(forKey: Key.priceLevel.rawValue)))!
    types = aDecoder.decodeObject(forKey: Key.types.rawValue) as! [String]
    website = aDecoder.decodeObject(forKey: Key.website.rawValue) as? URL
    image = aDecoder.decodeObject(forKey: Key.image.rawValue) as! PlaceImage
    
    let latitude = aDecoder.decodeDouble(forKey: Key.latitude.rawValue)
    let longitude = aDecoder.decodeDouble(forKey: Key.longitude.rawValue)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  
}

// MARK: - Place (From FPlace & GMSPlace) -

extension Place {
  
  convenience init(firebasePlace fPlace: FPlace, googleMapsPlace gmPlace: GMSPlace) {
    let types = gmPlace.types.map { $0.replacingOccurrences(of: "_", with: " ") }
    let image = PlaceImage(thumbnail: fPlace.thumbnailURL,
                           medium: fPlace.mediumURL, large: fPlace.largeURL)
    
    self.init(
      placeID: gmPlace.placeID,
      name: fPlace.name,
      summary: fPlace.summary,
      detailDescription: fPlace.detailDescription,
      phoneNumber: gmPlace.phoneNumber,
      coordinate: gmPlace.coordinate,
      formattedAddress: gmPlace.formattedAddress,
      rating: gmPlace.rating,
      priceLevel: PlacePriceLevel(rawValue: gmPlace.priceLevel.rawValue)!,
      types: types,
      website: gmPlace.website,
      image:  image
    )
  }
  
}
