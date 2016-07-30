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

// MARK: PlaceDetailsViewController: UIViewController

class PlaceDetailsViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var placeTypesLabel: UILabel!
    @IBOutlet weak var placeSummaryLabel: UILabel!
    @IBOutlet weak var placeDescriptionLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    @IBOutlet weak var placePhoneNumberLabel: UILabel!
    @IBOutlet weak var placeWebsiteLabel: UILabel!
    @IBOutlet weak var placeRatingView: HCSStarRatingView!
    @IBOutlet weak var placePriceLevelLabel: UILabel!
    
    
    // MARK: Instance Variables
    
    var place: Place!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(place != nil, "Place must exist!")
        
        configureUI()
    }
    
}

// MARK: - PlaceDetailsViewController (UI Functions)  -

extension PlaceDetailsViewController {
    
    private func configureUI() {
        title = place.name
        
        placeTitleLabel.text = place.name
        placeTypesLabel.text = "Types: \(place.types.joinWithSeparator(", "))"
        placeSummaryLabel.text = "Summary: \(place.summary)"
        placeDescriptionLabel.text = "Description: \(place.detailDescription)"
        placeRatingView.value = CGFloat(place.rating)
        
        placeAddressLabel.text = (place.formattedAddress != nil
            ? "Address: \(place.formattedAddress!)"
            : nil)
        placePhoneNumberLabel.text = (place.phoneNumber != nil
            ? "Phone number: \(place.phoneNumber!)"
            : nil)
        placeWebsiteLabel.text = (place.website != nil
            ? "Website: \(place.website!.host!)"
            : nil)
        placePriceLevelLabel.text = (place.priceLevel.title() != nil
            ? "Price level: \(place.priceLevel.title())"
            : nil)
        
        ImageDownloadManager.sharedInstance.imageForURL(place.image.mediumURL) { [weak self] (image, error) in
            guard error == nil else { return print("Failed to load image: \(error!.localizedDescription)") }
            self?.placeImageView.image = image
        }
    }
    
}
