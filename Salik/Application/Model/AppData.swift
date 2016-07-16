//
//  AppData.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit
import CoreLocation

class AppData: NSObject {
    
    class var sharedInstance: AppData {
        struct Static {
            static let instance: AppData = AppData()
        }
        return Static.instance
    }
    


    
    var car_info: [[String : String]]!
    var car_image = [String]()
    var selected_car_index: Int!
    var isSelectedCar: Bool!
    
    var isSelectedDeliery: Bool!
    
    var order_current_location: CLLocationCoordinate2D!
    var order_location_latitude: Double!
    var order_location_longitude: Double!
    var order_location_address: String!
    var user_comment: String!
    var user_phone_number: String!
    var apns_id: String!
    
    var user_city: String!
    var driver_info: [Dictionary<String,AnyObject>]!
    var order_driver_info: NSDictionary!
    var cars: [Dictionary<String, String>]!
    
    var order_id: Int!
    
    override init() {
        user_comment = ""
        user_phone_number = ""
        order_location_address = ""
        apns_id = ""
        
        car_info = [
            [
                "car_type": "Economy(QAR 30)",
                "car_image" : "economy"
            ],
            [
                "car_type": "SUV(QAR 80)",
                "car_image" : "suv"
            ],
            [
                "car_type": "VIP(QAR 150)",
                "car_image" : "vip"
            ],
            [
                "car_type": "VVIP(QAR 250)",
                "car_image" : "vvip"
            ],

        ]
        
        car_image = ["economy", "suv", "vip", "vvip"]
  
        
        selected_car_index = -1
        isSelectedCar = false
        
        isSelectedDeliery = false
        
        driver_info = []
        cars = []
        
        order_id = -1;
        
    }
    

}
