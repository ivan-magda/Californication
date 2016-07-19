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
}

enum PlacePriceLevel: Int {
    case Unknown = -1
    case Free
    case Cheap
    case Medium
    case High
    case Expensive
}

// MARK: - Place: NSObject, NSCoding

class Place: NSObject, NSCoding {
    
    struct Image {
        let thumbnailStorageURL: String
        let mediumStorageURL: String
        let largeStorageURL: String
    }
    
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
    let website: NSURL?
    
    init(placeID: String, name: String, summary: String, detailDescription: String, phoneNumber: String?, coordinate: CLLocationCoordinate2D, formattedAddress: String?, rating: Float, priceLevel: PlacePriceLevel, types: [String], website: NSURL?) {
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
        
        super.init()
    }
    
    // MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(placeID, forKey: Key.placeID.rawValue)
        aCoder.encodeObject(name, forKey: Key.name.rawValue)
        aCoder.encodeObject(summary, forKey: Key.summary.rawValue)
        aCoder.encodeObject(detailDescription, forKey: Key.detailDescription.rawValue)
        aCoder.encodeObject(phoneNumber, forKey: Key.phoneNumber.rawValue)
        aCoder.encodeDouble(coordinate.latitude, forKey: Key.latitude.rawValue)
        aCoder.encodeDouble(coordinate.longitude, forKey: Key.longitude.rawValue)
        aCoder.encodeObject(formattedAddress, forKey: Key.formattedAddress.rawValue)
        aCoder.encodeFloat(rating, forKey: Key.rating.rawValue)
        aCoder.encodeInt(Int32(priceLevel.rawValue), forKey: Key.priceLevel.rawValue)
        aCoder.encodeObject(types, forKey: Key.types.rawValue)
        aCoder.encodeObject(website, forKey: Key.website.rawValue)
    }
    
    required init?(coder aDecoder: NSCoder) {
        placeID = aDecoder.decodeObjectForKey(Key.placeID.rawValue) as! String
        name = aDecoder.decodeObjectForKey(Key.name.rawValue) as! String
        summary = aDecoder.decodeObjectForKey(Key.summary.rawValue) as! String
        detailDescription = aDecoder.decodeObjectForKey(Key.detailDescription.rawValue) as! String
        phoneNumber = aDecoder.decodeObjectForKey(Key.phoneNumber.rawValue) as? String
        formattedAddress = aDecoder.decodeObjectForKey(Key.formattedAddress.rawValue) as? String
        rating = aDecoder.decodeFloatForKey(Key.rating.rawValue)
        priceLevel = PlacePriceLevel(rawValue: Int(aDecoder.decodeIntForKey(Key.priceLevel.rawValue)))!
        types = aDecoder.decodeObjectForKey(Key.types.rawValue) as! [String]
        website = aDecoder.decodeObjectForKey(Key.website.rawValue) as? NSURL
        
        let latitude = aDecoder.decodeDoubleForKey(Key.latitude.rawValue)
        let longitude = aDecoder.decodeDoubleForKey(Key.longitude.rawValue)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}

// MARK: - Place (From FPlace & GMSPlace) -

extension Place {
    
    convenience init(firebasePlace fPlace: FPlace, googleMapsPlace gmPlace: GMSPlace) {
        let types = gmPlace.types.map { $0.stringByReplacingOccurrencesOfString("_", withString: " ") }
        
        self.init(
            placeID: gmPlace.placeID,
            name: gmPlace.name,
            summary: fPlace.summary,
            detailDescription: fPlace.detailDescription,
            phoneNumber: gmPlace.phoneNumber,
            coordinate: gmPlace.coordinate,
            formattedAddress: gmPlace.formattedAddress,
            rating: gmPlace.rating,
            priceLevel: PlacePriceLevel(rawValue: gmPlace.priceLevel.rawValue)!,
            types: types,
            website: gmPlace.website
        )
    }
    
}
