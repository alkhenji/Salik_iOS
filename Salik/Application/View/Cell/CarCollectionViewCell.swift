//
//  CarCollectionViewCell.swift
//  Salik
//
//  Created by ME on 6/7/16.
//  Copyright © 2016 com. All rights reserved.
//

import UIKit

class CarCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var car_image: UIImageView!
    @IBOutlet weak var car_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initData()
    }
    
    
    
    func initData(){
    }

    
    func setTextColor(){
        car_name.textColor = UIColor.blueColor();
    }
    
    func setBoarder(){
          AppController.sharedInstance.setBorderView(cellView, color: UIColor.blackColor(), width: 2.0)
    }
    
    func resetBorder(){
        AppController.sharedInstance.setBorderView(cellView, color: UIColor.blackColor(), width: 0.0)
    }
}
