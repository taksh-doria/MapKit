//
//  ViewController.swift
//  TestMapKit
//
//  Created by maverick on 19/09/20.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var placemarkinfo: UILabel!
    let locationmanager=CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        locationmanager.delegate=self
        map.delegate=self
        locationmanager.desiredAccuracy = kCLLocationAccuracyBest
        locationmanager.requestWhenInUseAuthorization()
        locationmanager.requestLocation()
        // Do any additional setup after loading the view.
    }
    func centerLocation(coordinate:CLLocationCoordinate2D?)
    {
        map.removeOverlays(map.overlays)
         if let coordinate=coordinate
         {
            print("inside here")
            let region=MKCoordinateRegion(center:coordinate , latitudinalMeters: 1000, longitudinalMeters: 1000)
            map.showsUserLocation=true
            map.setRegion(region, animated: true)
         }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton)
    {
        if let location=textfield.text
        {
            let coder=CLGeocoder()
            coder.geocodeAddressString(location) { (plcaemark, error)
                in
                guard let mark=plcaemark
                else
                {
                    return
                }
                guard let firstmark=mark.first
                else{ return }
                print(mark.first.debugDescription)
                print(mark.description.description)
                self.placemarkinfo.text=firstmark.locality
                let request=self.genreateRouteRequest(destination: MKPlacemark(placemark: firstmark))
                if let parsed_req=request
                {
                    let directions=MKDirections(request: parsed_req)
                    directions.calculate { (response, error) in
                        guard let parsed_res=response
                        else{ return }
                        for route in parsed_res.routes
                        {
                            self.map.addOverlay(route.polyline)
                            self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func genreateRouteRequest(destination:MKPlacemark) -> MKDirections.Request?
    {
        guard let location=locationmanager.location?.coordinate
        else
        {
            return nil
        }
        locationmanager.requestLocation()
        let start=MKPlacemark(coordinate: location)
        let request=MKDirections.Request()
        request.source=MKMapItem(placemark: start)
        request.destination=MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes=true
        return request
    }
}
//MARK: Location manager delegate methods
extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("inside did update locations method")
        print(locations.first?.coordinate.latitude)
        print(locations.first?.coordinate.longitude)
        centerLocation(coordinate: locations.last?.coordinate)
    }
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
}

//MARK: Mapkit delegate methods
extension ViewController:MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("inside mapkit delegate methods")
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .green
        return render
    }
}
