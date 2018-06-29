//
//  ViewController.swift
//  testOfMap
//
//  Created by user on 6/15/18.
//  Copyright © 2018 JJF. All rights reserved.
//

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
        //myMapView.showsTraffic = true
        //myMapView.showsPointsOfInterest = true
        
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

        var urlString = "https://data.cityofnewyork.us/resource/qiz3-axqb.json?"
        urlString = urlString.appending("&borough=BROOKLYN") // number_of_pedestrians_injured
        urlString = urlString.appending("&$limit=100") // &query=Swift
        let nycOpenDataURL = URL(string: urlString)!
        var urlRequest = URLRequest(url: nycOpenDataURL)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        let dataQueryTask = URLSession.shared.dataTask(with: urlRequest) {
            data, response, error in
            guard let data = data, error == nil else { // check for fundamental networking error
                return
            }
            do {
                //create json object from data
                if let rawJSON = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray {
                    let numberOfCrashes = rawJSON!.count as Int
                    for k in 0...(numberOfCrashes-2) {
                        if let crash = rawJSON?[k] as? NSDictionary {
                            let borough = crash["borough"] as! String
                            let longitudeString = crash["longitude"] as? String
                            if longitudeString == nil {
                            } else {
                                let latitudeString = crash["latitude"] as! String
                                let longitude = Double(longitudeString!)
                                let latitude = Double(latitudeString)
                                let pedestrianKilledString = crash["number_of_pedestrians_killed"] as! String
                                let pedestrianInjString = crash["number_of_pedestrians_injured"] as! String
                                let pedestrianInj = Int(pedestrianInjString)
                                if pedestrianInj! > 0 {
                                    // print(longitude!, latitude!)
                                    // print(pedestrianInj)
                                    let location = CLLocationCoordinate2D(latitude: latitude!,
                                                                          longitude: longitude!)
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = location
                                    
                                    // The code below (until END OF MARKER CHANGE) is an attempt at changing the appearance of each crash marker
                                    var annotationView = self.myMapView.dequeueReusableAnnotationView(withIdentifier: "demo")
                                    if annotationView == nil {
                                        annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "demo")
                                        annotationView!.canShowCallout = true
                                    }
                                    else {
                                        annotationView!.annotation = annotation
                                    }
                                    annotationView!.image = UIImage(named: "crashdot")
                                    // END OF MARKER CHANGE
                                    
                                    self.myMapView.addAnnotation(annotation)
                                }
                            }
                        } else {
                        }
                    }
                } else {
                }
            } catch {
            }
        }
        // New tasks are always created in the Suspended state. So we have to resume them
        dataQueryTask.resume()
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        mapView.setCenter(userLocation.coordinate, animated: true)
//    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 1
        return renderer
    }
    
    // The code below (until END OF NEW MAPVIEW) is an attempt at changing the appearance of each crash marker
    func mapView(_ mapView: MKMapView!, viewFor annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            //pinView!.animatesDrop = true
            pinView!.image = UIImage(named:"crashdot")!
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    // END OF NEW MAPVIEW
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

