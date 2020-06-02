//
//  SignInViewModel.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/29/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class SignInViewModel: NSObject {
    
    func signIn(email: String?, password: String?, completionHandler: @escaping (Error?) -> Void){
        FireBaseManager.shared.signIn(email: email ?? "default value", password: password ?? "no password") { (error) in
        if error != nil {
            print(error?.localizedDescription ?? "could not sign in")
            completionHandler(error)
        } else {
            print("Succesfully signed in")
            completionHandler(nil)
            }
        }
    }
    
    func signUp(user : UserModel, completionHandler: @escaping (Error?) -> Void){
        FireBaseManager.shared.createUser(user: user) { (error) in
            if error == nil {
                print("Created a user")
                completionHandler(nil)
            } else {
                completionHandler(error)
                print("Could not create a user")
            }
        }
    }

    
    
}
