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
import GoogleMaps

// MARK: CannedGoogleMapsNetworkManager: GoogleMapsNetworkManager

class CannedGoogleMapsNetworkManager: GoogleMapsNetworkManager {
  
  // MARK: GoogleMapsNetworkManager
  
  func placeWithID(_ id: String, success: @escaping GoogleMapsNetworkPlaceResponse,
                   failure: @escaping GoogleMapsFailureBlock) {
    GMSPlacesClient().lookUpPlaceID(id) { (place, error) in
      guard let place = place else { return failure(error) }
      success(place)
    }
  }
  
  func placesWithIDs(_ ids: [String], success: @escaping GoogleMapsNetworkPlacesResponse,
                     failure: @escaping GoogleMapsFailureBlock) {
    var places = [GMSPlace]()
    let client = GMSPlacesClient()
    
    func processOnResponse(_ place: GMSPlace?, error: Error?) {
      guard let place = place else { return failure(error) }
      places.append(place)
      
      if places.count == ids.count {
        success(places)
      }
    }
    
    ids.forEach { client.lookUpPlaceID($0, callback: processOnResponse) }
  }
  
}
