//
//  ChatCollectionViewCell.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/21/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit


class ChatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sentMessage: UITextView!
    @IBOutlet weak var recievedMessage: UITextView!
    
    override func awakeFromNib() {
        sentMessage.layer.cornerRadius = 10
        recievedMessage.layer.cornerRadius = 10
    }
    
    
     func updateCell(msgBody: String, status: String){
        if status == "send"{
            sentMessage.isHidden = false
            recievedMessage.isHidden = true
            sentMessage.text = msgBody
        } else {
            recievedMessage.isHidden = false
            sentMessage.isHidden = true
            recievedMessage.text = msgBody
        }
    }
}
