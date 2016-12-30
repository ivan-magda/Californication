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

// MARK: PlaceDirector: PlaceDirectorFacade

final class PlaceDirector: PlaceDirectorFacade {
  
  // MARK: Properties
  
  var firebaseDirector: FirebaseDirector
  var googleMapsDirector: GoogleMapsDirector
  let cacheManager: PlaceCacheManager
  
  // MARK: Init
  
  init(firebaseDirector: FirebaseDirector, googleMapsDirector: GoogleMapsDirector,
       cacheManager: PlaceCacheManager) {
    self.firebaseDirector = firebaseDirector
    self.googleMapsDirector = googleMapsDirector
    self.cacheManager = cacheManager
  }
  
  // MARK: PlaceDirectorFacade
  
  func all(_ success: @escaping PlaceDirectorSuccessBlock, failure: @escaping PlaceDirectorFailureBlock) {
    firebaseDirector.all { [unowned self] fPlaces in
      let ids = fPlaces.map { $0.googlePlaceID }
      
      self.googleMapsDirector.places(with:
        ids,
        success: { [unowned self] gmPlaces in
          let places = self.link(fPlaces, with: gmPlaces)
          success(places)
        },
        failure: failure
      )
    }
  }
  
  func save(_ places: [Place]) {
    cacheManager.save(places)
  }
  
  func persisted() -> [Place]? {
    return cacheManager.unarchived()
  }
  
  // MARK: Helpers
  
  private func link(_ fPlaces: [FPlace], with gmPlaces: [GMSPlace]) -> [Place] {
    guard fPlaces.count == gmPlaces.count else { return [] }
    
    var places = [Place]()
    fPlaces.forEach { fPlace in
      let gmPlace = gmPlaces.filter { $0.placeID == fPlace.googlePlaceID }.first
      if let gmPlace = gmPlace {
        let place = Place(firebasePlace: fPlace, googleMapsPlace: gmPlace)
        places.append(place)
      }
    }
    
    return places
  }
  
}
