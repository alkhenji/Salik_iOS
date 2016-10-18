//
//  AppDelegate.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit
import GoogleMaps
import AdSupport


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var appController: AppController = AppController.sharedInstance
    var appData: AppData = AppData.sharedInstance
    var storyBoard: UIStoryboard!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
       // IQKeyboardManager.sharedManager().enable = true

        sleep(2)

        GMSServices.provideAPIKey(GOOGLE_MAP_API_KEY)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 804.17 //0.5 miles
        
        
        //Notification setting
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Notification Delegate
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

       // let deviceTokenString: String = (String(data: deviceToken.base64EncodedData(), encoding: .utf8))!

        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        

        print("Device Token---> "+deviceTokenString)
        appData.apns_id = deviceTokenString
    }
    
    func application( _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error ) {
        
        print( error.localizedDescription )
    }
    
 
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("USER_INFO--->\(userInfo)")
        
        let aps : NSDictionary = (userInfo["aps"] as? NSDictionary)!
//        let alert = aps.objectForKey("alert") as! String
        
        let info = aps.object(forKey: "info") as! NSDictionary
        
        let order_state = info.object(forKey: "order_state") as! Int
        if order_state == 2 {
            showConfirmViewController()
        } else if order_state == 1 {
            hideConfirmViewController()
        } else if order_state == 3{
            goHome()
        }
        
        appData.order_driver_info = info.object(forKey: "driver_info") as! NSDictionary
      
    }
    
    func showConfirmDialog(_ alert: String){
        let alertController = UIAlertController(title: "Salik Notification", message: alert, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            self.showConfirmViewController()
        }
        alertController.addAction(okAction)
        
        
       self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    
    func showConfirmViewController(){
        let viewController = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "ConfirmViewController") as! ConfirmViewController
        
        // Then push that view controller onto the navigation stack
        let rootViewController = self.window!.rootViewController as! UINavigationController
        rootViewController.pushViewController(viewController, animated: true)
        
    }
    
    func hideConfirmViewController(){
        let rootViewController = self.window!.rootViewController as! UINavigationController
        rootViewController.popViewController(animated: true)

    }
    
    
    func goHome() {
        let rootViewController = self.window!.rootViewController as! UINavigationController
        rootViewController.popToRootViewController(animated: true)
    }
    
    func sign(){
        let params: NSMutableDictionary = NSMutableDictionary()
        params.setValue(appData.order_location_latitude, forKey: ORDER_LOCATION_LATITUDE)
        params.setValue(appData.order_location_longitude, forKey: ORDER_LOCATION_LONGITUDE)
        params.setValue(appData.user_city, forKey: USER_CITY)
        
        print(params)
        
        appController.httpRequest(API_SIGN, params: params, completion: {
            result in
            
                let status: Int = result.object(forKey: STATUS) as!  Int
                if status == 1 {
                    
                    let drivers: [Dictionary<String,AnyObject>]! = result.object(forKey: DRIVERS) as! [Dictionary<String,AnyObject>]!
                    self.appData.driver_info = drivers

                }
            
        }, errors: {
                
        })
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address: GMSAddress = response?.firstResult() {
                
                let lines = address.lines
                print("LocationAddress\(lines)")
                self.appData.order_location_address = lines!.joined(separator: " ")
                self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: lines!.joined(separator: " ") as AnyObject)

                self.appData.user_city = address.locality
//                self.appData.order_location_latitude = 25.2854
//                self.appData.order_location_longitude = 51.5310
//                self.appData.user_city = "Doha"
                
                self.sign()
            }
        }
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print(location)
            appData.order_current_location = location.coordinate
            
            self.appData.order_location_latitude = location.coordinate.latitude
            self.appData.order_location_longitude = location.coordinate.longitude
            
//            CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: { (placemarks, error) -> Void in
//                
//                if (error != nil) {
//                    print("Error: " + error!.localizedDescription)
//                    return
//                }
//                
//                if placemarks!.count > 0 {
//                    
//                    let pm = placemarks![0] as CLPlacemark
//                    self.displayLocationInfo(pm)
//
//                } else {
//                    print("Error with data")
//                }
//            })
            reverseGeocodeCoordinate(location.coordinate)
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
//    func displayLocationInfo(placemark: CLPlacemark) {
//        self.locationManager.stopUpdatingLocation()
//        
//        let subStreet = placemark.subThoroughfare
//        let street = placemark.thoroughfare
//        let postalCode = placemark.postalCode
//        let subDepartment = placemark.subAdministrativeArea
//        let department = placemark.administrativeArea
//        let city = placemark.locality
//        let country = placemark.country
//        let latitude = placemark.location!.coordinate.latitude
//        let longitude = placemark.location!.coordinate.longitude
//        let date = placemark.location!.timestamp
//        
//        print(subStreet)
//        print(street)
//        print(postalCode)
//        print(subDepartment)
//        print(department)
//        print(city)
//        print(country)
//        print(latitude)
//        print(longitude)
//        print(date)
//        
//        appData.user_location_latitude = latitude
//        appData.user_location_longitude = longitude
//        appData.user_location_address = street!+","+department!+","+city!+","+country!
//        
//        self.sign()
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while updating location " + error.localizedDescription)
    }
}

