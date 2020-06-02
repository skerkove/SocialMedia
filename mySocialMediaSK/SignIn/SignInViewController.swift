//
//  SignInViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/28/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    let signInVM = SignInViewModel()

    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundedButton(button: loginButton)
        roundedButton(button: signUpButton)
        // Do any additional setup after loading the view.
    }
    
    func roundedButton(button : UIButton){
        button.clipsToBounds = true
        button.layer.cornerRadius = button.bounds.height / 2
    }

    @IBAction func loginTapped(_ sender: UIButton) {
        signInVM.signIn(email: emailTxtField.text, password: passwordTxtField.text) { (error) in
            if error == nil {
                let ctrl = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                ctrl.modalPresentationStyle = .fullScreen
                self.present(ctrl, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let signUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        signUpVC.modalPresentationStyle = .fullScreen
        self.present(signUpVC, animated: true, completion: nil)
    }
}

