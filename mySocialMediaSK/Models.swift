//
//  Models.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/28/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import Foundation
import UIKit

struct UserModel {
    let userId : String?
    let email : String?
    let password : String?
    var userImage : UIImage?
    var firstName : String?
    var lastName : String?
}

struct PostModel {
    let timestamp : Double?
    let userId : String?
    var postBody : String?
    let date : String?
    var postImage : UIImage?
    var postId : String?
}

struct MessageModel {
    let timestamp : Double?
    let recepientId : String?
    let date : String?
    var msgBody : String?
    let status : String?
}
