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
  
  fileprivate lazy var locationManager: CLLocationManager = {
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    UIApplication.shared.statusBarStyle = .default
  }
  
  // MARK: Private
  
  fileprivate func configureMapView() {
    mapView.delegate = self
    
    // Center on California.
    let camera = GMSCameraPosition.camera(withLatitude: 37.0, longitude: -120.0, zoom: 6.0)
    mapView.camera = camera
    
    checkLocationAuthorizationStatus()
    addLocationMarkers()
  }
  
  fileprivate func checkLocationAuthorizationStatus() {
    if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
      setAuthorizedWhenInUseState()
    } else {
      locationManager.requestWhenInUseAuthorization()
    }
  }
  
  fileprivate func addLocationMarkers() {
    guard let places = placeDirector.persistedPlaces() else { return }
    places.forEach { place in
      let locationMarker = GMSMarker(position: place.coordinate)
      locationMarker.map = mapView
      locationMarker.userData = ["id": place.placeID]
      locationMarker.title = place.name
      locationMarker.appearAnimation = kGMSMarkerAnimationPop
      locationMarker.icon = GMSMarker.markerImage(with: .red)
      locationMarker.opacity = 0.95
      locationMarker.isFlat = true
      locationMarker.snippet = place.summary
    }
  }
  
}

// MARK: - MapViewController: CLLocationManagerDelegate -

extension MapViewController: CLLocationManagerDelegate {
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == CLAuthorizationStatus.authorizedWhenInUse {
      setAuthorizedWhenInUseState()
    } else {
      setUserNotAuthorizedState()
    }
  }
  
  // MARK: Helpers
  
  fileprivate func setAuthorizedWhenInUseState() {
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  fileprivate func setUserNotAuthorizedState() {
    mapView.isMyLocationEnabled = false
    mapView.settings.myLocationButton = false
  }
  
}

// MARK: - MapViewController: GMSMapViewDelegate -

extension MapViewController: GMSMapViewDelegate {
  
  func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
    guard let dictionary = marker.userData as? [String: String],
      let id = dictionary["id"],
      let places = placeDirector.persistedPlaces(),
      let index = places.index(where: { $0.placeID == id }) else { return }
    let place = places[index]
    
    didSelect(place)
  }
  
}
