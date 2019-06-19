//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Pavel on 6/11/19.
//  Copyright © 2019 Pavel. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    var place = Place()
    let annotationIdentifier  = "annotationIdentifier"
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupPlacemark()
        checkLocationServices()
    }

    private func setupPlacemark() {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { (placemarks, error) in

            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks  else { return }
            let placemark  = placemarks.first

            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle  = self.place.type

            guard let placemarkLocation = placemark?.location else { return }

            annotation.coordinate = placemarkLocation.coordinate

            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorisation()
        } else {
            showAlert(title: "Location services are disabled",
                      message: "To enable it go: Settings -> Privacy -> Location -> Location Services. And turn On"
            )
        }
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    private func checkLocationAuthorisation() {
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
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("new case in location manager authorisation status avialable")
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) // TODO:  add seague to system preference
        alert.addAction(okAction)
        DispatchQueue.main.asyncAfter(deadline: .now()  + 1)  {
            self.present(alert, animated: true)
        }
    }

    @IBAction func shiftToUserLocation(_ sender: Any) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)

        }
    }
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }

        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return  annotationView
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorisation()
    }
}
