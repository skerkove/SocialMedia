//
//  UpdateViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/14/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class UpdateViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    var currentUser : UserModel?
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var deleteProfileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        setupImagePicker()
//        getUserInfo()
    }
    override func viewWillAppear(_ animated: Bool) {
        getUserInfo()
    }

    @IBAction func updateUser(_ sender: UIButton) {
        let newUserData = UserModel(userId: currentUser?.userId, email: currentUser?.email, password: currentUser?.password, userImage: userImageView.image, firstName: firstNameText.text, lastName: lastNameText.text)
        FireBaseManager.shared.updateUser(user: newUserData) { (error) in
            if error == nil {
                print("Succesfully updated user")
                
            } else {
                print(error?.localizedDescription ?? "Could not update user")
            }
        }
    }

    func getUserInfo(){
        FireBaseManager.shared.getUserData { (user) in
            if user != nil {
                self.currentUser = user
                self.firstNameText.text = user?.firstName
                
                self.lastNameText.text = user?.lastName
          
                self.getImage()
            }else {
                print("Error happened")
            }
        }
    }
    
    @IBAction func deleteProfileTapped(_ sender: UIButton) {
        FireBaseManager.shared.deleteUser { (error) in
            if error != nil {
                print("Could not delete user")
            } else {
                print("user deleted succesfully")
            }
        }
        let signIn = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignViewController") as! SignInViewController
        UIApplication.shared.keyWindow?.rootViewController = signIn
    }
    
    @IBAction func pickImageTapped(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func setupImagePicker() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let fetchedImage = info[.editedImage] as? UIImage else {
            print("Error, image is not found")
            return
            }
        FireBaseManager.shared.saveUserImg(image: fetchedImage) { (error) in
            if error == nil {
                self.userImageView.image = fetchedImage
                print("Succesfully updated image")
            } else {
                print(error?.localizedDescription ?? "couldnt save image")
            }
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func getImage(){
        FireBaseManager.shared.getUserImg { (data, error) in
            if error == nil {
                self.userImageView.image = UIImage(data: data!) ?? UIImage()
            } else {
                self.userImageView.image = UIImage(named: "userPlaceholder")
                print( error?.localizedDescription ?? "Could not fetch image")
            }
        }
    }
    

}
