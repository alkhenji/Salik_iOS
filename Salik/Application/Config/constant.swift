//
//  Constant.swift
//  Salik
//
//  Created by ME on 6/8/16.
//  Copyright © 2016 com. All rights reserved.
//
import UIKit
import Foundation

    //Google API Key
//    let GOOGLE_MAP_API_KEY = "AIzaSyCBK7r5sI-fzFKymy0hrTBV7L1QX00xPpU"
    let GOOGLE_MAP_API_KEY = "AIzaSyAjM43wAuIvvtT_mGo63p7UOPCPfFASrqE"
    let GOOGLE_PLYA_SERVICE_KEY = "AIzaSyCB4nwxbd99-jHkw_C6Nk1q8J73EnugHAs"
    
    //API URL
//    let SERVER_URL = "http://172.16.1.192:8080/Salik"
//    let SERVER_URL = "http://138.128.178.90/~oczxbfkm/Salik/index.php"
    let SERVER_URL = "http://salikappqatar.com/Salik/index.php"



    let API_KEY = "12345"
    let API_URL = SERVER_URL + "/api"
    let API_SIGN = SERVER_URL + "/api/sign"
    let API_GET_CARS = SERVER_URL + "/api/getCars"
    let API_ORDER = SERVER_URL + "/api/order"
    let API_ORDER_CANCEL = SERVER_URL + "/api/orderCancel"


    // Request Params (Order)
    let ORDER_CAR_TYPE_ID = "order_car_type_id"
    let ORDER_CAR_TYPE = "order_car_type"
    let ORDER_LOCATION_ADDRESS = "order_location_address"
    let ORDER_LOCATION_LATITUDE = "order_location_latitude"
    let ORDER_LOCATION_LONGITUDE = "order_location_longitude"
    let ORDER_COMMENT = "order_comment"
    let ORDER_PHONE_NUMBER = "order_phone_number"
    let ORDER_ID = "order_id"
    let APNS_ID = "apns_id";
    let USER_CITY = "user_city"
    let CARS = "cars"

    //Result
    let STATUS = "status"
    let MESSAGE = "msg"

    //Driver Info
    let DRIVERS = "drivers"
    let DRIVER_ID = "driver_id"
    let DRIVER_NAME = "driver_name"
    let DRIVER_LOCATION_ADDRESS = "driver_location_address"
    let DRIVER_LOCATION_LATITUDE = "driver_location_latitude"
    let DRIVER_LOCATION_LONGITUDE = "driver_location_longitude"
    let DRIVER_DISTANCE = "distance"

    let DRIVER_PHONE_NUMBER = "driver_phone_number"

    var orderVC: OrderViewController!
