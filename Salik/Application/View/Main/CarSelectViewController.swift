//
//  CarSelectViewController.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class CarSelectViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deliveryView: UIView!
    @IBOutlet var btnCallForRent: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CarSelectViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeLeft)

        self.initUI()
    }
    
    func initUI(){
        self.collectionView.backgroundColor = UIColor.white
       // btnCallForRent.layer.cornerRadius = 5.0
    }
    
    //MARK: Custom Action
    @IBAction func next(_ sender: UIButton) {
        if appData.selected_car_index == -1 {
            let alertController = appController.showAlert("Warning!", message: "Please select your ride.")
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "UserInfoViewController") as! UserInfoViewController
            pushFromLeft(nextViewController)
        }
        
    }
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        var cellSize: CGSize!
        
        // Please if you want to fit more cars, change numbers here for grid
        
        let kCellForRow: CGFloat = 1
        let kCellForLine: CGFloat = 3.1
        
        let width: CGFloat = (collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - 10)/kCellForRow
        let height: CGFloat = (collectionView.frame.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom - 10)/kCellForLine
        cellSize = CGSize(width: width, height: height)
        
        return cellSize // The size of one cell
    }
    
    // #MARK: - CollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var num: Int!
        
        num = appData.car_info.count;
//        num = appData.cars.count - 1;
        
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: CarCollectionViewCell!
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carCollectionViewCell", for: indexPath) as! CarCollectionViewCell
        
        cell.car_image.image = UIImage(named: appData.car_info[(indexPath as NSIndexPath).row]["car_image"]!)
        
        cell.car_name.text = appData.car_info[(indexPath as NSIndexPath).row]["car_type"]
        
//        cell.car_image.image = UIImage(named: appData.car_image[indexPath.row])
//        cell.car_name.text = appData.cars[indexPath.row]["car_type_name"]

        if (indexPath as NSIndexPath).row == appData.selected_car_index {
            cell.setBoarder()
        } else {
            cell.resetBorder()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        // Select operation
        if indexPath.row <= 1{
            appData.isSelectedCar = true
            appData.selected_car_index = (indexPath as NSIndexPath).row
            self.collectionView.reloadData()

        }else{
            self.showCallAlert()
        }

//        initDeliveryView()
        
    }

    func showCallAlert(){
        // create the alert
        let strText = "You will be calling our Toll-Free Customer Call Center to help you with renting a car.\n سوف يتم الإتصال بالرقم المجاني لمركز خدمة العملاء لمساعدتك في تأجير سيارة."
        let alert = UIAlertController(title: "Call and rent a car", message: strText, preferredStyle: UIAlertControllerStyle.alert)

        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Call", style: UIAlertActionStyle.default, handler: { action in
            let url = URL(string: "tel://8000005")
            UIApplication.shared.openURL(url!)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))

        // show the alert
        self.present(alert, animated: true, completion: nil)

    }

//    @IBAction func deliveryAction(sender: UIButton) {
//        initCollectionView()
//        appData.isSelectedDeliery = !(appData.isSelectedDeliery)
//        if (appData.isSelectedDeliery == true) {
//            setBorderView()
//            appData.selected_car_index = 4 //4 is delivery id
//        } else{
//            resetBorderView()
//        }
//    }
    
    func setBorderView() {
//         appController.setBorderView(deliveryView, color: UIColor.blackColor(), width: 2.0)
    }
    
    func resetBorderView() {
//        appController.setBorderView(deliveryView, color: UIColor.blackColor(), width: 0.0)
    }
    
    func initCollectionView() {
        appData.isSelectedCar = false
        
//        if (appData.selected_car_index > -1){
//            appData.selected_car_index = -1
//        }
        self.collectionView.reloadData()
    }
    @IBAction func OnBtnCallForRent(_ sender: AnyObject) {
           }
    
    func initDeliveryView() {
        appData.isSelectedDeliery = false
        resetBorderView()
    }

    func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
               // print("Swiped right")
                popFromRight()
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
            case UISwipeGestureRecognizerDirection.left:
//                initCollectionView()
                print("Swipe left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}
