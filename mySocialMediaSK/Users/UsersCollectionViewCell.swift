//
//  UsersCollectionViewCell.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/29/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit
import Firebase

protocol FriendsDelegate {
    func addFriend()
}

class UsersCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var addFriendIcon: UIButton!
    
    var userId: String?
    var isFriend : Bool?
    var delegate : UsersViewController?
    
    func updateCell(img : UIImage, name: String, id: String){
        userNameLabel.text = name
        userImage.image = img
        userId = id
        
        
    }
    
    
    @IBAction func addFriendTapped(_ sender: UIButton) {
        guard let id = userId else { return }
        FireBaseManager.shared.addFriend(friendId: id) { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "Could not add a friend")
            } else {
                self.addFriendIcon.isHidden = true
                print("Succesfully added a friend")
            }
            self.delegate?.addFriend()
        }
    }
    
}
