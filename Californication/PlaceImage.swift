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

// MARK: Types

private enum Key: String {
  case thumbnail
  case medium
  case large
}

// MARK: PlaceImage: NSObject, NSCoding

class PlaceImage: NSObject, NSCoding {
  
  // MARK: Properties
  
  let thumbnailURL: String
  let mediumURL: String
  let largeURL: String
  
  // MARK: Init
  
  init(thumbnail: String, medium: String, large: String) {
    thumbnailURL = thumbnail
    mediumURL = medium
    largeURL = large
    
    super.init()
  }
  
  // MARK: NSCoding
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(thumbnailURL, forKey: Key.thumbnail.rawValue)
    aCoder.encode(mediumURL, forKey: Key.medium.rawValue)
    aCoder.encode(largeURL, forKey: Key.large.rawValue)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let thumbnail = aDecoder.decodeObject(forKey: Key.thumbnail.rawValue) as! String
    let medium = aDecoder.decodeObject(forKey: Key.medium.rawValue) as! String
    let large = aDecoder.decodeObject(forKey: Key.large.rawValue) as! String
    
    self.init(thumbnail: thumbnail, medium: medium, large: large)
  }
  
}
