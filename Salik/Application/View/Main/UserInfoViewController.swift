//
//  UserInfoViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }

        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }

        return fromIndex ..< toIndex
    }
}

class UserInfoViewController: BaseViewController, UIScrollViewDelegate, UITextFieldDelegate, GooglePlacesAutocompleteDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var commonTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carTypeLabel: UILabel!

    var contectYPos : CGFloat = 0.0
    var bIsMapView : Bool = false

    var currentTextField: UITextField!
    
    var gpaViewController: GooglePlacesAutocomplete!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contectYPos = self.contentView.frame.origin.y

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)


        gpaViewController = GooglePlacesAutocomplete(
            apiKey: GOOGLE_PLYA_SERVICE_KEY,
            placeType: .all
        )

        gpaViewController.placeDelegate = self
        gpaViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: gpaViewController, action: #selector(Stream.close))
        gpaViewController.locationBias = LocationBias(latitude: 25.286106, longitude: 51.534817, radius: 10000)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CarSelectViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeLeft)
        
        self.initUI()
        self.initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLocation()
        bIsMapView = false
    }
    
    func initView(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserInfoViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        phoneTextField.keyboardType = UIKeyboardType.numberPad
        phoneTextField.returnKeyType = UIReturnKeyType.done
        phoneTextField.delegate = self

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45))
        let button = UIButton(frame: CGRect(x: self.view.frame.size.width - 60 , y: 0, width: 50, height: 45))
        button.setTitle("Done", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)

        button.addTarget(self, action: #selector(dismissKeyboard) , for: UIControlEvents.touchUpInside) //addTarget(self, action: #selector(dismissKeyboard), forControlEvents: .TouchUpInside)
        customView.addSubview(button)

        customView.backgroundColor = UIColor.init(colorLiteralRed: 45.0/255.0, green: 190.0/255.0, blue: 221.0/255.0, alpha: 1.0)
        phoneTextField.inputAccessoryView = customView
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

    func keyboardWillShow(notification: NSNotification) {
        if !bIsMapView {
             if self.contentView.frame.origin.y == contectYPos{
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.contentView.frame.origin.y -= 110.0
                })
            }
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if !bIsMapView {
             if self.contentView.frame.origin.y != contectYPos{
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.contentView.frame.origin.y += 110.0
                })
            }
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
        self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: locationTextField.text! as AnyObject)
        let onlyPhoneNumber:String = (phoneTextField.text?.replacingOccurrences(of: "+974 ", with: ""))!

        appData.user_phone_number = onlyPhoneNumber
        self.appController.setUserDefault(ORDER_PHONE_NUMBER, val: onlyPhoneNumber as AnyObject)
        appData.user_comment = commonTextField.text
    }
    
    
    //MARK: Custom Action
    
    @IBAction func next(_ sender: UIButton) {
        if locationTextField.text!.isEmpty {
            let alertController = appController.showAlert("Warning!", message: "Enter your location.")
            self.present(alertController, animated: true, completion: nil)
            return
        } else if phoneTextField.text!.isEmpty{
            let alertController = appController.showAlert("Warning!", message: "Enter your phone number.")
            self.present(alertController, animated: true, completion: nil)
            return
        }else if !phoneValidat(){
            let alertController = appController.showAlert("Warning!", message: "Enter a valid phone number.")
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            getUserInfo()
            order()
        }
    }
    
    @IBAction func onMap(_ sender: UIButton){
        if appData.order_location_address == "" || appData.order_current_location == nil{
            let alertController = appController.showAlert("Warning!", message: "Sorry, You can\' t open map because your location was disabled. Please enter your location manually.")
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            let mapViewController = self.storyboard!.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            self.navigationController?.pushViewController(mapViewController, animated: true)
        }
    }
    
    func phoneValidat() -> Bool{
        let onlyPhoneNumber:String = (phoneTextField.text?.replacingOccurrences(of: "+974 ", with: ""))!
        let phoneNumber:Int? = Int(onlyPhoneNumber)

        if onlyPhoneNumber.characters.count != 8 || phoneNumber < 30000000 || phoneNumber > 79999999 {
            return false
        }

        return true
    }
    
    // MARK: Order
    
    fileprivate func order(){
                let window = UIApplication.shared.keyWindow!
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
        
                    DispatchQueue.main.async(execute: {
                        self.appController.hideActivityIndicator(window)
        
                    })
        
                    let status: Int = result.object(forKey: STATUS) as!  Int
                    if status == 1 {
                        self.appData.order_id = result.object(forKey: ORDER_ID) as! Int
                        self.appController.setUserDefault(ORDER_ID, val: result.object(forKey: ORDER_ID)! as AnyObject)
                        DispatchQueue.main.async {
                            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "OrderViewController") as! OrderViewController
                            self.pushFromLeft(nextViewController)
                        }
 
                    } else if status == 2{
                        DispatchQueue.main.async(execute: {
                            let alertController = self.appController.showAlert("Warning!", message: "You have already ordered!")
                            self.present(alertController, animated: true, completion: nil)
                            return
                        })
                    }
                    else if status == 0{
                        DispatchQueue.main.async(execute: {
                            let alertController = self.appController.showAlert("Warning!", message: "Sorry!, You can't order now. Please try again later.")
                            self.present(alertController, animated: true, completion: nil)
                            return
                        })
                    }
                    }, errors:{
                        DispatchQueue.main.async(execute: {
                            self.appController.hideActivityIndicator(window)
        
                        })
                        DispatchQueue.main.async(execute: {
                            let alertController = self.appController.showAlert("Error!", message: "Check your Internet connection!")
                            self.present(alertController, animated: true, completion: nil)
                            return
                        })
                })
    }
    
    //MARK: TextField Delegate
 
    @IBAction func OnBtnLocation(_ sender: AnyObject) {
        self.dismissKeyboard()
        bIsMapView = true
        present(gpaViewController, animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       // if textField == locationTextField {
        //    present(gpaViewController, animated: true, completion: nil)
       // }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if (textField == phoneTextField) {

            let currentText = textField.text ?? ""
            guard let stringRange = range.range(for: currentText) else { return false }

            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

            if updatedText.characters.count == 1{
                phoneTextField.text = "+974 "
            }else if updatedText.characters.count < 5 {
                return false
            }

            return updatedText.characters.count <= 13
        }
        return true
    }


    //GooglePlacesAutoComplete Delegate
    func placesFound(_ places: [Place]) {
        
    }
    
    func placeSelected(_ place: Place) {
        appData.order_location_address = place.desc
        self.appController.setUserDefault(ORDER_LOCATION_ADDRESS, val: place.desc as AnyObject)
        
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
        self.gpaViewController.gpaViewController.tableView.isHidden = true
         dismiss(animated: true, completion: nil)
    }
    
    func initAppData(){
        locationTextField.text = ""
        phoneTextField.text = ""
        commonTextField.text = ""
        //appData.selected_car_index = -1;
        //appData.isSelectedDeliery = false
    }
    
    
    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
                popFromRight()
                initAppData()
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}
