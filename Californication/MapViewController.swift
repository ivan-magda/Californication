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
import GoogleMaps

// MARK: MapViewController: UIViewController

class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: Properties
    
    var didSelect: (Place) -> () = { _ in }
    var placeDirector: PlaceDirectorFacade!
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        return locationManager
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(placeDirector != nil)
        
        configureMapView()
    }
    
    // MARK: Private
    
    private func configureMapView() {
        mapView.delegate = self
        
        // Center on California.
        let camera = GMSCameraPosition.cameraWithLatitude(37.0, longitude: -120.0, zoom: 6.0)
        mapView.camera = camera
        
        checkLocationAuthorizationStatus()
        addLocationMarkers()
    }
    
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView.settings.myLocationButton = true
            mapView.myLocationEnabled = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func addLocationMarkers() {
        guard let places = placeDirector.persistedPlaces() else { return }
        places.forEach { place in
            let locationMarker = GMSMarker(position: place.coordinate)
            locationMarker.map = mapView
            locationMarker.userData = ["id": place.placeID]
            locationMarker.title = place.name
            locationMarker.appearAnimation = kGMSMarkerAnimationPop
            locationMarker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
            locationMarker.opacity = 0.75
            locationMarker.flat = true
            locationMarker.snippet = place.summary
        }
    }
    
}

// MARK: - MapViewController: CLLocationManagerDelegate -

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            mapView.myLocationEnabled = true
        }
    }
    
}

// MARK: - MapViewController: GMSMapViewDelegate -

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(mapView: GMSMapView, didTapInfoWindowOfMarker marker: GMSMarker) {
        guard let dictionary = marker.userData as? [String: String],
            id = dictionary["id"],
            places = placeDirector.persistedPlaces(),
            index = places.indexOf({ $0.placeID == id }) else { return }
        let place = places[index]
        
        didSelect(place)
    }
    
}
