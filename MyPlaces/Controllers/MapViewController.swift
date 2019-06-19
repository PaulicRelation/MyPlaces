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

protocol MapViewControllerDelegate {
    func getAddress(_ adress: String?)
}

class MapViewController: UIViewController {


    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImmage: UIImageView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    var place = Place()
    var mapViewControllerDelegate: MapViewControllerDelegate?

    let annotationIdentifier  = "annotationIdentifier"
    let locationManager = CLLocationManager()
    var incomeSegueIdentifier = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
    }

    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            mapPinImmage.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            setupPlacemark()
        }
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
            if incomeSegueIdentifier == "GetAddress" { showUserLocation() }
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

    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    @IBAction func shiftToUserLocation(_ sender: Any) {
        showUserLocation()
    }
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true)
    }
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(currentAddressLabel.text)
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

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error { print(error); return }
            guard let placemarks = placemarks else { return }

            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare

            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    self.currentAddressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.currentAddressLabel.text  = "\(streetName!)"
                } else { self.currentAddressLabel.text = "" }
            }
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorisation()
    }
}
