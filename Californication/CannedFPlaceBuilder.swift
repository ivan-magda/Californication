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
import FirebaseDatabase

// MARK: CannedFPlaceBuilder: FPlaceBuilder

class CannedFPlaceBuilder: FPlaceBuilder {
    
    // MARK: FPlaceBuilder
    
    func placesFromResponse(response: FIRDataSnapshot) -> [FPlace] {
        return response.children.flatMap { self.placeFromSnapshot($0 as! FIRDataSnapshot) }
    }
    
    // MARK: Helpers
    
    private func placeFromSnapshot(snapshot: FIRDataSnapshot) -> FPlace? {
        let dictionary = snapshot.value as! [String: AnyObject]
        
        guard let placeID = dictionary[FPlace.Key.placeId.rawValue] as? String,
            summary = dictionary[FPlace.Key.summary.rawValue] as? String,
            description = dictionary[FPlace.Key.detailDescription.rawValue] as? String,
            images = dictionary[FPlace.Key.images.rawValue] as? [String: String],
            thumbnail = images[FPlace.Key.thumbnail.rawValue],
            medium = images[FPlace.Key.medium.rawValue],
            large = images[FPlace.Key.large.rawValue] else { return nil }
        
        return FPlace(googlePlaceID: placeID, summary: summary, detailDescription: description, thumbnailStorageURL: thumbnail, mediumStorageURL: medium, largeStorageURL: large)
    }
    
}
