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
import Alamofire
import AlamofireImage

// MARK: Typealiases

typealias ImageDownloadManagerCompletionHandler = (_ image: UIImage?, _ error: Error?) -> Void

// MARK: Constants

private let placeImagesCacheName = "place-images"

// MARK: - ImageDownloadManager

final class ImageDownloadManager {
  
  // MARK: Properties
  
  static let shared = ImageDownloadManager()
  let imageCache: ImageCache?
  
  // MARK: Init
  
  private init() {
    imageCache = ImageCache(placeImagesCacheName)
  }
  
  // MARK: Methods
  
  func image(for url: String, completion: @escaping ImageDownloadManagerCompletionHandler) {
    if let cachedImage = imageCache?.lookUpImageInCache(with: url) {
      completion(cachedImage, nil)
    } else {
      Alamofire.request(url).responseImage { [unowned self] response in
        let result = response.result
        guard let image = result.value else {
          completion(nil, result.error)
          return
        }
        
        self.imageCache?.cache(image, with: url)
        completion(image, nil)
      }
    }
  }
  
}
