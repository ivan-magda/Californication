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

// MARK: App

class App {
    
    // MARK: Properties
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let tabBarController: UITabBarController
    let placeListViewController: PlaceListViewController
    let mapViewController: MapViewController
    
    let placeDirector: PlaceDirector
    
    // MARK: Init
    
    init(window: UIWindow) {
        let fDirector = FirebaseDirector(builder: CannedFirebaseBuilder(),
                                         databaseManager: CannedFirebaseManager())
        let gmDirector = GoogleMapsDirector(networkManager: CannedGoogleMapsNetworkManager())
        placeDirector = PlaceDirector(firebaseDirector: fDirector, googleMapsDirector: gmDirector,
                                      cacheManager: CannedPlaceCacheManager())
        
        tabBarController = window.rootViewController as! UITabBarController
        
        mapViewController = tabBarController.viewControllers![1] as! MapViewController
        mapViewController.placeDirector = placeDirector
        
        let navigationController = tabBarController.viewControllers![0] as! UINavigationController
        placeListViewController = navigationController.topViewController as! PlaceListViewController
        placeListViewController.placeDirector = placeDirector
        
        placeListViewController.didSelect = pushPlace
        mapViewController.didSelect = presentPlace
    }
    
    // MARK: Navigation
    
    func pushPlace(place: Place) {
        let detailVC = placeDetailsViewControllerWithPlace(place)
        detailVC.title = "Detail"
        placeListViewController.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func presentPlace(place: Place) {
        let detailVC = placeDetailsViewControllerWithPlace(place)
        tabBarController.presentViewController(detailVC, animated: true, completion: nil)
    }
    
    private func placeDetailsViewControllerWithPlace(place: Place) -> PlaceDetailsViewController {
        let controller = storyboard.instantiateViewControllerWithIdentifier("PlaceDetails") as! PlaceDetailsViewController
        controller.place = place
        
        return controller
    }
    
}
