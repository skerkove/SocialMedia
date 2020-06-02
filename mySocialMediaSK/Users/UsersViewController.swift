//
//  UsersViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/29/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var usersCollectionView: UICollectionView!
    
    var arrUsers = [UserModel]()
    var isFriend = [Bool]()
    var arrOfFriends = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        getAllUsers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllFriends()

        print(arrUsers.count)
    }
    
    func getAllUsers() {
        FireBaseManager.shared.getAllUsers { (arrUsers) in
            guard let users = try? arrUsers else {return}
            self.arrUsers = users
            if self.arrUsers.count == 0 {
                print("no users")
                return
            }else{
                    self.usersCollectionView.reloadData()
            }
        }
    }
    func getAllFriends(){
        FireBaseManager.shared.getAllFriends { [weak self] (array) in
            guard let friends = try? array else {
                return
            }
            for friend in friends {
                if let friendId = friend.userId {
                    self?.arrOfFriends.append(friendId)
                }
            }
            DispatchQueue.main.async {
                self?.usersCollectionView.reloadData()
            }
        }
    }
    
    func checkIfFriend(_ uid: String) -> Bool {
        if arrOfFriends.contains(uid){
            return true
        }
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = usersCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! UsersCollectionViewCell
        let user = arrUsers[indexPath.row]
        cell.updateCell(img: user.userImage ?? UIImage(named: "placeholder")!, name: "\(user.firstName ?? "first name") \(user.lastName ?? "last name")" , id: user.userId ?? "unknow id")
        cell.addFriendIcon.isHidden = checkIfFriend(user.userId!)
        cell.addFriendIcon.isEnabled = !checkIfFriend(user.userId!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var arrayOfPosts = [PostModel]()
        let user = arrUsers[indexPath.row]
        
        let st = UIStoryboard(name: "Main", bundle: nil)
//        let vc = st.instantiateViewController(withIdentifier: "UserDetailViewController") as! UserDetailViewController
//        vc.user = user
//        vc.fullName = (user.name ?? "") + " " +  (user.lastName ?? "")
        FireBaseManager.shared.getAllPostsByUserId(id: user.userId!) { (array) in
            guard let postsArr = array else { return }
            arrayOfPosts = postsArr
            DispatchQueue.main.async {
//                vc.arrPosts = arrayOfPosts
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated:  true)
            }

        }
    }
    func addFriend() {
        getAllFriends()
    }
    



}
