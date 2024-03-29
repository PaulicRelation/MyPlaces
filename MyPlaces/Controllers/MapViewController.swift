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
    @IBOutlet weak var mapPinImmage: UIImageView!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!

    var place = Place()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                self.previousLocation = currentLocation
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }

    let mapManager = MapManager()
    let annotationIdentifier  = "annotationIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView()
    }

    private func setupMapView() {
        goButton.isHidden = true
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate  = self
        }
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImmage.isHidden = true
            currentAddressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden =  false
        }
    }
    @IBAction func shiftToUserLocation(_ sender: Any) {
        mapManager.showUserLocation(mapView: mapView) }
    @IBAction func closeVC(_ sender: Any) {
        dismiss(animated: true) }
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(currentAddressLabel.text)
        dismiss(animated: true) }
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
}

protocol MapViewControllerDelegate {
    func getAddress(_ adress: String?)
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
        let center = mapManager.getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        geocoder.cancelGeocode()
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

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorisation(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
