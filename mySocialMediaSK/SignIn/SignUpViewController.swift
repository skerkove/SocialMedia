//
//  SignUpViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/29/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    let signInVM = SignInViewModel()
    
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var confirmTxtField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundedButton(button: signUpButton)
        roundedButton(button: cancelButton)

    }
    func roundedButton(button : UIButton){
        button.clipsToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let user = UserModel(userId: nil, email: emailTxtField.text, password: passwordTxtField.text, userImage: nil, firstName: firstNameTxtField.text, lastName: lastNameTxtField.text)
        signInVM.signUp(user: user) { (error) in
            if error == nil{
                let tabVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarController") as! TabBarController
                tabVC.modalPresentationStyle = .fullScreen
                self.present(tabVC, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
