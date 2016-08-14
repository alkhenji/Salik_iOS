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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CarSelectViewController.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeLeft)

        self.initUI()
    }
    
    func initUI(){
        self.collectionView.backgroundColor = UIColor.whiteColor()

    }
    
    //MARK: Custom Action
    @IBAction func next(sender: UIButton) {
        if appData.selected_car_index == -1 {

            let alertController = appController.showAlert("Warning!", message: "Please select your ride.")
            self.presentViewController(alertController, animated: true, completion: nil)
            return
        } else{
            
            let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("UserInfoViewController") as! UserInfoViewController
            pushFromLeft(nextViewController)
        }
        
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var cellSize: CGSize!
        
        let kCellForRow: CGFloat = 2
        let kCellForLine: CGFloat = 2
        
        let width: CGFloat = (collectionView.frame.size.width - collectionView.contentInset.left - collectionView.contentInset.right - 10)/kCellForRow
        let height: CGFloat = (collectionView.frame.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom - 10)/kCellForLine
        cellSize = CGSizeMake(width, height)
        
        return cellSize // The size of one cell
    }
    
    // #MARK: - CollectionViewDelegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var num: Int!
        
        num = appData.car_info.count;
//        num = appData.cars.count - 1;
        
        return num
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell: CarCollectionViewCell!
        cell = collectionView.dequeueReusableCellWithReuseIdentifier("carCollectionViewCell", forIndexPath: indexPath) as! CarCollectionViewCell
        cell.car_image.image = UIImage(named: appData.car_info[indexPath.row]["car_image"]!)
        cell.car_name.text = appData.car_info[indexPath.row]["car_type"]
//        cell.car_image.image = UIImage(named: appData.car_image[indexPath.row])
//        cell.car_name.text = appData.cars[indexPath.row]["car_type_name"]

        if indexPath.row == appData.selected_car_index {
            cell.setBoarder()
        } else{
            cell.resetBorder()
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        appData.isSelectedCar = true
        appData.selected_car_index = indexPath.row
        self.collectionView.reloadData()
        
        initDeliveryView()
        
    }
    
    @IBAction func deliveryAction(sender: UIButton) {
        initCollectionView()
        appData.isSelectedDeliery = !(appData.isSelectedDeliery)
        if (appData.isSelectedDeliery == true) {
            setBorderView()
            appData.selected_car_index = 4 //4 is delivery id
        } else{
            resetBorderView()
        }
    }
    
    func setBorderView() {
         appController.setBorderView(deliveryView, color: UIColor.blackColor(), width: 2.0)
    }
    
    func resetBorderView() {
        appController.setBorderView(deliveryView, color: UIColor.blackColor(), width: 0.0)
    }
    
    func initCollectionView() {
        appData.isSelectedCar = false
        appData.selected_car_index = -1
        self.collectionView.reloadData()
    }
    
    func initDeliveryView() {
        appData.isSelectedDeliery = false
        resetBorderView()
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
                appData.selected_car_index = -1
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
}
