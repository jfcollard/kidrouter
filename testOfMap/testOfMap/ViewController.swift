//
//  ViewController.swift
//  testOfMap
//
//  Created by user on 6/15/18.
//  Copyright © 2018 JJF. All rights reserved.
//
// This comment was made by JF
import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var myMapView: MKMapView!
    var locationManager = CLLocationManager.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        let location = CLLocationCoordinate2D(latitude: 40.6736381,
                                              longitude: -73.9829144)
        
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let region = MKCoordinateRegion(center: location, span: span)
        myMapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Home"
        annotation.subtitle = "Apt 4L"
        myMapView.addAnnotation(annotation)
        myMapView.delegate = self
        myMapView.mapType = .hybrid //.standard
        myMapView.showsUserLocation = true
        myMapView.showsScale = true
        myMapView.showsCompass = true
        myMapView.showsTraffic = true
        myMapView.showsPointsOfInterest = true
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.6736381, longitude:-73.9829144 ), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.76381, longitude: -74.0059), addressDictionary: nil))
        request.requestsAlternateRoutes = true
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.myMapView.add(route.polyline)
                self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
        
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        mapView.setCenter(userLocation.coordinate, animated: true)
//    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        return renderer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

