//
//  MapViewController.swift
//  Salik
//
//  Created by Rob Mans on 6/9/16.
//  Copyright © 2016 Salik. All rights reserved.
//

import UIKit
import GoogleMaps


class MapViewController: BaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let marker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView.delegate = self
        
        initData()
        initView()
        addMakerForAllDriver()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        popFromRight()
    }
    
    func initData(){
        
    }
    
    func initView(){
        reverseGeocodeCoordinate(self.appData.order_current_location)
        setMaker(self.appData.order_current_location)
        marker.map = mapView
    }

    
    func setMaker(_ coordinate: CLLocationCoordinate2D){
        marker.position = coordinate;
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.icon = UIImage(named: "map_pin")
        marker.title = "I am here"
        marker.snippet = addressLabel.text
        
        mapView.selectedMarker = marker
    }
    
    func addMakerForDriver(_ driver: Dictionary<String, AnyObject>){
        let driverMaker = GMSMarker()

        let latitude = String(describing: driver[DRIVER_LOCATION_LATITUDE]!)
        let longitude = String(describing: driver[DRIVER_LOCATION_LONGITUDE]!)
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(latitude)!, Double(longitude)!)
        driverMaker.position = coordinate
        driverMaker.appearAnimation = kGMSMarkerAnimationPop
        let driver_name : String = driver[DRIVER_NAME] as! String
        driverMaker.title = "Driver(" + driver_name + ")"
        driverMaker.snippet = String(describing: driver[DRIVER_LOCATION_ADDRESS]!)
        
        
        driverMaker.map = mapView
        
    }
    
    func addMakerForAllDriver(){
        for driver in appData.driver_info {
            addMakerForDriver(driver)
        }
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines
                print(lines)
                self.addressLabel.text = lines!.joined(separator: " ")
                self.appData.order_location_address = self.addressLabel.text
                self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: lines!.joined(separator: " ") as AnyObject)

                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                }) 
                
                self.setMaker(coordinate)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
            locationManager.stopUpdatingLocation()

        }
        
    }
    
    //MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        reverseGeocodeCoordinate(position.target)
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        reverseGeocodeCoordinate(coordinate)
        appData.order_location_latitude = coordinate.latitude
        appData.order_location_longitude = coordinate.longitude
        
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.camera = GMSCameraPosition(target: self.appData.order_current_location, zoom: 15, bearing: 0, viewingAngle: 0)

        reverseGeocodeCoordinate(self.appData.order_current_location)
        appData.order_location_latitude = appData.order_current_location.latitude
        appData.order_location_longitude = appData.order_current_location.longitude
        return true
    }

}
