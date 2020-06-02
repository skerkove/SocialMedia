//
//  SettingsViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/14/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var updatePasswordButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        roundedButton(button: updateProfileButton)
        roundedButton(button: updatePasswordButton)
        roundedButton(button: logOutButton)
    }
    

    func roundedButton(button : UIButton){
        button.clipsToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        do
        {
             try Auth.auth().signOut()
        }
        catch let error as NSError
        {
            print (error.localizedDescription)
        }
        let signInVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        UIApplication.shared.keyWindow?.rootViewController = signInVC
    }
    

}
