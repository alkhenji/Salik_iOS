//
//  UserInfoViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class UserInfoViewController: BaseViewController, UIScrollViewDelegate, UITextFieldDelegate, GooglePlacesAutocompleteDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var commonTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carTypeLabel: UILabel!
    

    var currentTextField: UITextField!
    
    var gpaViewController: GooglePlacesAutocomplete!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gpaViewController = GooglePlacesAutocomplete(
            apiKey: GOOGLE_PLYA_SERVICE_KEY,
            placeType: .Address
        )

        gpaViewController.placeDelegate = self
        gpaViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: gpaViewController, action: #selector(NSStream.close))

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CarSelectViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)
        
        self.initUI()
        self.initView()
    }
    
    override func viewWillAppear(animated: Bool) {
        updateLocation()
    }
    
    func initView(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserInfoViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        phoneTextField.keyboardType = UIKeyboardType.NumberPad
        phoneTextField.returnKeyType = UIReturnKeyType.Done
        
    }
    
    func initUI(){
        if appData.isSelectedCar == true {
            carImageView.image = UIImage(named: appData.car_info[appData.selected_car_index]["car_image"]!)
            carTypeLabel.text = appData.car_info[appData.selected_car_index]["car_type"]
        } else if appData.isSelectedDeliery == true{
            carImageView.image = UIImage(named: "delivery.png")
            carTypeLabel.text = "QAR (20)"
        }

    }

    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)

    }

    func updateLocation(){
        locationTextField.text = appData.order_location_address
    }
    
    func getUserInfo() -> Void {
        appData.order_location_address = locationTextField.text
        self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: locationTextField.text!)
        appData.user_phone_number = phoneTextField.text
        self.appController.setUserDefault(ORDER_PHONE_NUMBER, val: phoneTextField.text!)
        appData.user_comment = commonTextField.text
    }
    
    
    //MARK: Custom Action
    
    @IBAction func next(sender: UIButton) {
        if locationTextField.text!.isEmpty {
            let alertController = appController.showAlert("Warning!", message: "Enter your location.")
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } else if phoneTextField.text!.isEmpty{
            let alertController = appController.showAlert("Warning!", message: "Enter your phone number.")
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        }else if !phoneValidat(){
            let alertController = appController.showAlert("Warning!", message: "Enter a valid phone number.")
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } else {
            getUserInfo()
            order()
        }
    }
    
    @IBAction func onMap(sender: UIButton){
        if appData.order_location_address == "" || appData.order_current_location == nil{
            let alertController = appController.showAlert("Warning!", message: "Sorry, You can\' t open map because your location was disabled. Please enter your location manually.")
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } else {
            let mapViewController = self.storyboard!.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    func phoneValidat() -> Bool{
        let phoneNumber:Int? = Int(phoneTextField.text!)
        if phoneTextField.text!.characters.count != 8 || phoneNumber < 30000000 || phoneNumber > 79999999{
            return false
        }
        
        return true

    }
    
    // MARK: Order
    
    private func order(){
                let window = UIApplication.sharedApplication().keyWindow!
                self.appController.showActivityIndicator(window)
        
                let params: NSMutableDictionary = NSMutableDictionary()
                params.setValue(appData.user_phone_number, forKey: ORDER_PHONE_NUMBER)
                params.setValue(appData.selected_car_index+1, forKey: ORDER_CAR_TYPE_ID)
                if appData.selected_car_index == 4{
                    params.setValue("(QAR 20)", forKey: ORDER_CAR_TYPE)

                } else{
                    params.setValue(appData.car_info[appData.selected_car_index]["car_type"], forKey: ORDER_CAR_TYPE)
//                    params.setValue(appData.cars[appData.selected_car_index]["car_type_name"], forKey: ORDER_CAR_TYPE)

                }
                params.setValue(appData.user_comment, forKey: ORDER_COMMENT)
                params.setValue(appController.getUserDefault(ORDER_LOCATION_ADDRESS), forKey: ORDER_LOCATION_ADDRESS)
                params.setValue(appData.order_location_latitude, forKey: ORDER_LOCATION_LATITUDE)
                params.setValue(appData.order_location_longitude, forKey: ORDER_LOCATION_LONGITUDE)
                params.setValue(appData.apns_id, forKey: APNS_ID)
        
        
                print(params)
                appController.httpRequest(API_ORDER, params: params, completion: {result in
        //            print("result \(result)")
        
                    dispatch_async(dispatch_get_main_queue(), {
                        self.appController.hideActivityIndicator(window)
        
                    })
        
                    let status: Int = result.objectForKey(STATUS) as!  Int
                    if status == 1 {
                        self.appData.order_id = result.objectForKey(ORDER_ID) as! Int
                        self.appController.setUserDefault(ORDER_ID, val: result.objectForKey(ORDER_ID)!)
                        dispatch_async(dispatch_get_main_queue()) {
                            let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("OrderViewController") as! OrderViewController
                            self.pushFromLeft(nextViewController)
                        }
 
                    } else if status == 2{
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = self.appController.showAlert("Warning!", message: "You have already ordered!")
                            self.presentViewController(alertController, animated: true, completion: nil)
                            return
                        })
                    }
                    else if status == 0{
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = self.appController.showAlert("Warning!", message: "Sorry!, You can't order now. Please try again later.")
                            self.presentViewController(alertController, animated: true, completion: nil)
                            return
                        })
                    }
                    }, errors:{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.appController.hideActivityIndicator(window)
        
                        })
                        dispatch_async(dispatch_get_main_queue(), {
                            let alertController = self.appController.showAlert("Error!", message: "Check your Internet connection!")
                            self.presentViewController(alertController, animated: true, completion: nil)
                            return
                        })
                })
    }
    
    //MARK: TextField Delegate
 
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == locationTextField {
            presentViewController(gpaViewController, animated: true, completion: nil)
            
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        return true
    }
    
    //GooglePlacesAutoComplete Delegate
    func placesFound(places: [Place]) {
        
    }
    
    func placeSelected(place: Place) {
        appData.order_location_address = place.desc
        self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: place.desc)
        
        self.gpaViewController.gpaViewController.searchBar.text = place.desc
        
        place.getDetails{details in
            print(details.latitude)
            print(details.longitude)
            
            self.appData.order_location_latitude = details.latitude;
            self.appData.order_location_longitude = details.longitude;
        }
    }
    
    func placeViewClosed() {
    
        self.gpaViewController.gpaViewController.searchBar.text = ""
        self.gpaViewController.gpaViewController.tableView.hidden = true
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    func initAppData(){
        locationTextField.text = ""
        phoneTextField.text = ""
        commonTextField.text = ""
        //appData.selected_car_index = -1;
        //appData.isSelectedDeliery = false
    }
    
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.Down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.Left:
                popFromRight()
                initAppData()
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}
