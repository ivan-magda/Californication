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
    let navigationController: UINavigationController
    
    let placeDirector: PlaceDirector
    
    // MARK: Init
    
    init(window: UIWindow) {
        navigationController = window.rootViewController as! UINavigationController
        let placeListVC = navigationController.topViewController as! PlaceListViewController
        
        let fDirector = FirebaseDirector(builder: CannedFirebaseBuilder(),
                                         databaseManager: CannedFirebaseManager())
        let gmDirector = GoogleMapsDirector(networkManager: CannedGoogleMapsNetworkManager())
        placeDirector = PlaceDirector(firebaseDirector: fDirector, googleMapsDirector: gmDirector)
        
        placeListVC.placeDirector = placeDirector
    }
    
    // MARK: Navigation
    
    func showPlace(movie: FPlace) {
        // TODO: Show place
    }
    
}
