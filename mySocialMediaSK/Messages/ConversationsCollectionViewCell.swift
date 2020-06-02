//
//  ConversationsCollectionViewCell.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/19/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit



class ConversationsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    func updateCell(name : String, image: UIImage){
        userImage.image = image
        userName.text = name
    }
}
