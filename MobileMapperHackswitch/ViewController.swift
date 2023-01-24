//
//  ViewController.swift
//  MobileMapperHackswitch
//
//  Created by Phipps, Jacob - Student on 1/12/23.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var parks: [MKMapItem] = []
    
    var currentLocation: CLLocation!
    
    @IBOutlet weak var MKMapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        MKMapView.showsUserLocation = true
        
    }
    
    
    @IBAction func whenSearchButtonPressed(_ sender: UIBarButtonItem) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Parks"
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            for mapItem in response.mapItems {
                self.parks.append(mapItem)
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.MKMapView.addAnnotation(annotation)
            }
        }
    }
    @IBAction func whenZoomButtonPressed(_ sender: UIBarButtonItem) {
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center = currentLocation.coordinate
        let region = MKCoordinateRegion(center: center, span: coordinateSpan)
        MKMapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations[0]
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "MobileMakerIconPinImage")
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        
        return pin
        
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        var currentMapItem = MKMapItem()
        if let coordinate = view.annotation?.coordinate {
            for mapitem in parks {
                if mapitem.placemark.coordinate.latitude == coordinate.latitude &&
                    
                    mapitem.placemark.coordinate.longitude == coordinate.longitude {
                    
                    currentMapItem = mapitem
                }
            }
        }
        let placemark = currentMapItem.placemark
        print(currentMapItem)
        if let parkName = placemark.name, let streetNumber = placemark.subThoroughfare, let streetName =
            placemark.thoroughfare
        {
            
            let streetAddress = streetNumber + " " + streetName
            
            let alert = UIAlertController(title: parkName, message: streetAddress, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
}
