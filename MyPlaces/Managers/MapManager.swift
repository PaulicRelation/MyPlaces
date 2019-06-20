//
//  MapManager.swift
//  MyPlaces
//
//  Created by Pavel on 6/20/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import MapKit

class MapManager {

    let locationManager = CLLocationManager()
    private var directionsArray: [MKDirections] = []
    private var placeCoordinate: CLLocationCoordinate2D?
    private let regionAreaInMeters: Double = 1000

    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    func startTrackingUserLocation(for mapView: MKMapView,
                                           and location: CLLocation?,
                                           closure:(_ currentLocation: CLLocation) -> ()) {

        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }

    func setupPlacemark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in

            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks  else { return }
            let placemark = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = place.name
            annotation.subtitle = place.type

            guard let placemarkLocation = placemark?.location else { return }

            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate

            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }

    func showUserLocation(mapView: MKMapView) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: self.regionAreaInMeters, longitudinalMeters: regionAreaInMeters)
            mapView.setRegion(region, animated: true)
        }
    }

    func checkLocationAuthorisation(mapView: MKMapView, segueIdentifier: String) {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            // TODO: - add seague to settings
            showAlert(title: "Access to your location is denied",
                      message: "To give permission go: Settings -> MyPlaces -> Location"
            )
        case .restricted:
            // TODO: - add seague to settings
            showAlert(title: "Access to your location is restricted",
                      message: "To give permission go: Settings -> MyPlaces -> Location"
            )
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if segueIdentifier == "GetAddress" { showUserLocation(mapView: mapView) }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("new case in location manager authorisation status avialable")
        }
    }

    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorisation(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            showAlert(title: "Location services are disabled",
                      message: "To enable it go: Settings -> Privacy -> Location -> Location Services. And turn On"
            )
        }
    }

    private func reset(mapView: MKMapView, withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }

    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) ->  MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else  { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true

        return request
    }

    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) ->()) {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))

        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
        let directions = MKDirections(request: request)
        reset(mapView: mapView, withNew: directions)

        directions.calculate { (response,  error) in
            if let error = error  { print(error); return }
            guard let response = response else {
                self.showAlert(title: "Error", message: "Destination is not avialable")
                return
            }
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)

                let distance =  String(format: "%.1f", route.distance /  1000)
                let timeInterval = route.expectedTravelTime
                print("distance: \(distance) km, time to destination \(timeInterval / 60 ) min")
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) // TODO:  add seague to system preference
        alert.addAction(okAction)

        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel  = UIWindow.Level.alert + 1
        alertWindow.makeKeyAndVisible()

        DispatchQueue.main.asyncAfter(deadline: .now()  + 1)  {
            alertWindow.rootViewController?.present(alert, animated: true)
        }
    }
}
