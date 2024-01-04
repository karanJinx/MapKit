//
//  ViewController.swift
//  GetUserCurrentLocation2
//
//  Created by Humworld Solutions Private Limited on 03/01/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addressLable: UILabel!
    @IBOutlet var goButtonToGetDirection: UIButton!
    @IBOutlet var currentLocationView: UIView!
    let locationManager = CLLocationManager()
    var regionInMeter: Double = 5000
    var previousLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationAuthorization()
        goButtonToGetDirection.layer.cornerRadius = 50
        currentLocationView.layer.cornerRadius = 10
    }
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            //show alert instuct them how to on location
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnLocation()
            locationManager.startUpdatingLocation()
            previousLocation = getCenterLocation(for: mapView)
        default:
            break
        }
    }
    func centerViewOnLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func checkLocationServices() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.setUpLocationManager()
                self.checkLocationAuthorization()
            } else {
                
            }
        }
            
        
    }
    @IBAction func currentLocationButtonPressed(_ sender: Any) {
            self.checkLocationServices()
        
    }
    @IBAction func goButtonPressed(_ sender: Any) {
        
    }
}

extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let region = MKCoordinateRegion(center: center, latitudinalMeters: regionInMeter, longitudinalMeters: regionInMeter)
//        mapView.setRegion(region, animated: true)
//    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

func getCenterLocation(for mapView: MKMapView) -> CLLocation {
    let latitude = mapView.centerCoordinate.latitude
    let longitude = mapView.centerCoordinate.longitude
    return CLLocation(latitude: latitude, longitude: longitude)
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        guard let previous = previousLocation else { return }
        guard center.distance(from: previous) > 50 else { return }
        self.previousLocation = center
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placeMarks, error) in
            guard let self = self else { return }
            if let _ = error {
                return
            }
            guard let placeMark = placeMarks?.first else { return }
            let streetNumber = placeMark.subThoroughfare ?? ""
            let streetName = placeMark.thoroughfare ?? ""
            let sublocality = placeMark.subLocality ?? ""
            let locality = placeMark.locality ?? ""
            let code = placeMark.postalCode ?? ""
            self.addressLable.text = "\(streetNumber),\(streetName), \(sublocality), \(locality) - \(code)"
        }
    }
}

//var locationManager: CLLocationManager = {
//    var manager = CLLocationManager()
//    manager.desiredAccuracy = kCLLocationAccuracyBest
//    return manager
//}()
//override func viewDidLoad() {
//    super.viewDidLoad()
//    // Do any additional setup after loading the view.
//    locationManager.delegate = self
//    locationManager.requestWhenInUseAuthorization()
////        updateLocaion(from: locationManager.location ?? CLLocation(), with: "Current location")
//}
//
//func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    guard let location = locations.last else { return }
//    updateLocaion(from: location, with: "Current location")
//}
//
//func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//    if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
//        locationManager.startUpdatingLocation()
//    }
//}
//
//func updateLocaion(from location: CLLocation, with title: String?) {
//    let annotation = MKPointAnnotation()
//    annotation.title = title
//    annotation.coordinate = location.coordinate
//    mapView.addAnnotation(annotation)
//    
//    let center = location.coordinate
//    let region = MKCoordinateRegion(center: center, latitudinalMeters: 5000, longitudinalMeters: 5000)
//    mapView.setRegion(region, animated: true)
//    mapView.mapType = .hybrid
//    locationManager.stopUpdatingLocation()
//}
