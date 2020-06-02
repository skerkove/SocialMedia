//
//  FeedCollectionViewCell.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/14/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var postTxt: UITextView!
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var postImg: UIImageView!
    
    var postId : String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundedImg(image: userImg)
        postImg.clipsToBounds = true
        
        let fixedWidth = postTxt.frame.size.width
               let newSize = postTxt.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
               postTxt.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    }
    
    
    func roundedImg(image : UIImageView){
        image.clipsToBounds = true
        let borderColor = UIColor.black.cgColor
        image.layer.borderColor = borderColor
        image.layer.borderWidth = 3
        image.layer.cornerRadius = image.bounds.width / 2
    }
    
    
    func updateCellWOImg(userImg: UIImage, userName: String, postBody: String, date: String){
        self.userImg.image = userImg
        self.userNameLbl.text = userName
        self.postTxt.text = postBody
        self.dateLbl.text = date
        
        self.postImg.isHidden = true
        self.postTxt.isHidden = false
        
    }
    func updateCellWOText(userImg: UIImage, postImg: UIImage, userName: String, date: String){
        self.userImg.image = userImg
        self.postImg.image = postImg
        self.userNameLbl.text = userName
        self.dateLbl.text = date
        
        self.postImg.isHidden = true
        self.postTxt.isHidden = false
    }
    func updateCell(userImg: UIImage, postImg: UIImage, userName: String, postBody: String, date: String){
        self.userImg.image = userImg
        self.postImg.image = postImg
        self.userNameLbl.text = userName
        self.postTxt.text = postBody
        self.dateLbl.text = date
        
        self.postImg.isHidden = false
        self.postTxt.isHidden = false
    }
}

