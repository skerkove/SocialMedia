//
//  ConversationsViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 4/19/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class ConversationsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var arrOfConversations = [[String : Any]]()
    
    @IBOutlet weak var userCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUsersInfoWithConversations()

    }
    override func viewWillAppear(_ animated: Bool) {
        getUsersInfoWithConversations()
    }
    
    func getUsersInfoWithConversations(){
        FireBaseManager.shared.getAllConversationsForUser { (arrOfUsersInfo) in
            if let array = arrOfUsersInfo {
                self.arrOfConversations = array
                self.userCollectionView.reloadData()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfConversations.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ConversationsCollectionViewCell
        let user = arrOfConversations[indexPath.row]
        var userImage : UIImage?
        let userName = "\(user["firstName"] as! String ?? "") \(user["lastName"] as! String ?? "")"
          if let image = user["userImg"] as? UIImage {
              userImage = image
          }
           else {
              userImage = UIImage(named: "placeholder")
          }
          cell.updateCell(name: userName, image: userImage!)
          return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let user = arrOfConversations[indexPath.row]
//        let st = UIStoryboard(name: "Main", bundle: nil)
//                let vc = st.instantiateViewController(withIdentifier: "ChatSharedViewController") as! ChatSharedViewController
//        vc.userId = user["userId"] as? String
//        vc.userName = "\(user["name"] as? String ?? "") \(user["lastName"] as? String ?? "")"
//        if let image = user["userImg"] as? UIImage {
//            vc.userImg = image
//        } else {
//            vc.userImg = UIImage(named: "userPlaceholder")
//        }
//        vc.getAllMessages(userId: ((user["userId"] as? String)!))
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//    }
//    


}
