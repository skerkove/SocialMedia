//
//  CreatePostViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/19/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CreatePostViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    let imagePicker = UIImagePickerController()
    let dateId = generateDate()
    let timestamp = NSDate().timeIntervalSince1970
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setUpImagePicker()
        postTextView.delegate = self
        postTextView.text = "What would you like to share..."
        postTextView.textColor = .lightGray
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPostTapped(_ sender: UIButton) {
        savePost()
        navigationController?.popViewController(animated: true)
    }
    
    func savePost(){
        let user = Auth.auth().currentUser
        let postM = PostModel(timestamp: timestamp, userId: user?.uid, postBody: postTextView.text, date: dateId, postImage: nil, postId: nil)
        FireBaseManager.shared.savePost(post: postM) { (error) in
            if error == nil {
                print("Succesfully created post")
                return
            } else {
                print(error?.localizedDescription ?? "Could not create a post")
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            postTextView.text = "What would you like to share..."
            postTextView.textColor = .lightGray
        } else {
            if textView.textColor == .lightGray {
                textView.text = nil
                textView.textColor = .black
            }
        }
    }
   //#################################################################################
    //imagePicker set up
    func setUpImagePicker() {
        imagePicker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        imagePicker.allowsEditing = true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let addedImg = info[.editedImage] as? UIImage else {
            print("Error, image is not found")
            return
        }
        FireBaseManager.shared.savePostImg(date: dateId, image: addedImg) { (error) in
            if error == nil {
                self.postImageView.image = addedImg
                print("Succesfully saved image")
            } else {
                print(error?.localizedDescription ?? "Couldnt save image")
            }
        }
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
}



func generateDate() ->String {
    let date = Date()
    let dateFormatter = DateFormatter()
    var dateId : String = ""
    dateFormatter.dateFormat = "MMMM-dd-yyyy HH:mm"
    dateId = dateFormatter.string(from: date)
    return dateId
}
