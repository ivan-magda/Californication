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

protocol PlaceImageHeaderViewDelegate {
    func placeImageHeaderViewCloseDidPressed(view: PlaceImageHeaderView)
}

// MARK: PlaceImageHeaderView: UIView

class PlaceImageHeaderView: UIView {
    
    // MARK: Outlets

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate: PlaceImageHeaderViewDelegate?
    
    // MARK: Properties
    
    var headerHeight: CGFloat = 300.0
    
    // MARK: Public
    
    func layoutSubviewsWithContentOffset(offset: CGPoint) {
        var headerRect = CGRect(x: 0, y: -headerHeight, width: bounds.width, height: headerHeight)
        if offset.y < -headerHeight {
            headerRect.origin.y = offset.y
            headerRect.size.height = -offset.y
        }
        
        frame = headerRect
    }
    
    @IBAction func closeButtonDidPressed(sender: AnyObject) {
        delegate?.placeImageHeaderViewCloseDidPressed(self)
    }

}
