//
//  FirebaseManager.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/28/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class FireBaseManager {
    static let shared = FireBaseManager()
    private init (){}

    let refDB = Database.database().reference()
    let refStorage = Storage.storage().reference()
    
    //create a user and sign in
    func createUser(user : UserModel, completionHandler: @escaping (Error?) -> Void){
        Auth.auth().createUser(withEmail: user.email!, password: user.password!) { (response, error) in
            if error != nil {
                completionHandler(error)
            } else {
                if let response = response?.user {
                    print("user successfully added, \(response.uid)")
                    let userDict = ["userId": response.uid,
                                    "email": user.email as Any,
                                    "password": user.password as Any,
                                    "firstName": user.firstName as Any,
                                    "lastName": user.lastName as Any] as [String : Any]
                    
                    self.refDB.child("User").child(response.uid).setValue(userDict){(error1, ref) in
                        if error == nil{
                            Auth.auth().signIn(withEmail: userDict["email"] as! String, password: userDict["password"] as! String, completion: { (newUser, error) in
                                if error == nil {
                                    print("succesfully signed in")
                                    completionHandler(nil)
                                } else {
                                    completionHandler(error)
                                }
                            })
                        } else {
                            completionHandler(error1)
                        }
                    }
                }
            }
        }
    }
    
    //sign in
    func signIn(email: String, password: String, completionHandler: @escaping (Error?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) {(user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error occured")
                completionHandler(error)
            } else {
                if let user = user?.user {
                    print(user.uid)
                }
                completionHandler(nil)
            }
        }
    }
    
    //log out
    func signOut(){
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
            } catch{
                print("Error occured signing out, \(error.localizedDescription)")
            }
        }
    }
    //get all users for Collection View
        func getAllUsers(completionHandler: @escaping ([UserModel]) -> Void){
        let currentUser = Auth.auth().currentUser
        let fetchUserGroup = DispatchGroup()
        let fetchUserComponentGroup = DispatchGroup()
        
        fetchUserGroup.enter()
        refDB.child("User").observeSingleEvent(of: .value) {(snapshot, error) in
            if error != nil {
                print(error ?? "Error happened fetching users")
            } else {
                var userArr = [UserModel]()
                guard let response = snapshot.value as? [String : Any] else {
                    return
                }
                for record in response {
                    let uid : String = record.key
                    if currentUser!.uid != uid {
                        let user = response[uid] as! [String : Any]
                        print(user)
                        var userM = UserModel(userId: uid, email: user["email"] as? String, password: user["password"] as? String, userImage: nil, firstName: user["firstName"] as? String, lastName: user["lastName"] as? String)
                        fetchUserComponentGroup.enter()
                        self.getUserImgById(id: uid) { (data, error) in
                            if error == nil && !(data == nil){
                                userM.userImage = UIImage(data: data!) ?? UIImage()
                            }
                            else {
                                userM.userImage = UIImage(named: "placeholder")
                            }
                            userArr.append(userM)
                            fetchUserComponentGroup.leave()
                        }
                    }
                }
                fetchUserComponentGroup.notify(queue: .main){
                    fetchUserGroup.leave()
                }
                fetchUserGroup.notify(queue: .main){
                    completionHandler(userArr)
                }
            }
        }
    }
    
    func getUserImgById(id: String, completionHandler: @escaping (Data?, Error?)->Void){
        let imageName = "UserImg/\(id).jpeg"
        refStorage.child(imageName).getData(maxSize: 1*500*500, completion: {(data, error) in
            completionHandler(data, error)
        })
    }
    
    func getUserById(userId: String, completionHandler: @escaping (UserModel?) -> Void){
        refDB.child("User").child(userId).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let record = snapshot.value as? [String : Any] else {
                    completionHandler(nil)
                    return
                }
            self.getUserImgById(id: userId, completionHandler: {(data, error) in
                print(error?.localizedDescription)
                    if error == nil && !(data == nil) {
                        let user = UserModel(userId: userId, email: record["email"] as? String, password: record["password"] as? String, userImage: UIImage(data: data ?? Data()), firstName: record["firstName"] as? String, lastName: record["lastName"] as? String)
                        completionHandler(user)
                    }
                    else {
                        let user = UserModel(userId: userId, email: record["email"] as? String, password: record["password"] as? String, userImage: nil, firstName: record["firstName"] as? String, lastName: record["lastName"] as? String)
                        completionHandler(user)
                }
            })
        })
    }
    
    func getPostImg(userId: String, date: String, completionHandler: @escaping (Data?, Error?) -> Void){
        let imgName = "PostImg/\(String(describing: userId))/\(String(describing: date)).jpeg"
        refStorage.child(imgName).getData(maxSize: 1*500*500) { (data, error) in
            completionHandler(data, error)
        }
    }



    func getAllPosts(completionHandler: @escaping ([[String : Any]]?) -> Void){
        let postsDispatchGroup = DispatchGroup()
        let userDispatchGroup = DispatchGroup()
        var postsArr = [[String : Any]]()
        refDB.child("Posts").observeSingleEvent(of: .value) { (snapshot, error) in
            if error == nil {
                guard let response = snapshot.value as? [String : Any] else {
                    completionHandler(nil)
                    return
                }
                for record in response {
                    var postDict = [String : Any]()
                    postsDispatchGroup.enter()
                    let pid = record.key
                    let post = response[pid] as! [String : Any]
                    userDispatchGroup.enter()
                    self.getUserById(userId: post["userId"] as! String) { (user) in
                
                            postDict["user"] = user
                        userDispatchGroup.leave()
                    }
                    var postM = PostModel(timestamp: post["timestamp"] as? Double, userId: post["userId"] as? String, postBody: post["postBody"] as? String, date: post["date"] as? String, postImage: nil, postId: post["postId"] as? String)
                    
                    postDict["postId"] = pid
                    postDict["timestamp"] = postM.timestamp
                    
                    self.getPostImg(userId: postM.userId!, date: postM.date!) { (data, error) in
                        if !(data == nil) && error == nil{
                            postM.postImage = UIImage(data: data!)
                        }
                        
                        postDict["post"] = postM
                        
                    }
                    userDispatchGroup.notify(queue: .main){
                        postsArr.append(postDict)
                        postsDispatchGroup.leave()
                    }
                }
                postsDispatchGroup.notify(queue: .main){
                    completionHandler(postsArr)
                }
            }
            
        }
    }
    
    func updateUser(user: UserModel, completionHandler: @escaping (Error?) -> Void) {
        let userID = (Auth.auth().currentUser?.uid)!
        let userDict = ["firstName": user.firstName as Any, "email" : user.email!, "password" : user.password!, "lastName": user.lastName as Any] as [String : Any]
        refDB.child("User").child(userID).updateChildValues(userDict) {(error, ref) in
            if error != nil{
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func getUserData(completionHandler: @escaping (UserModel?) -> Void){
        let user = Auth.auth().currentUser
        refDB.child("User").child(user!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let snap = snapshot.value as? [String : Any] else {
                    completionHandler(nil)
                    return
            }
            let userM = UserModel(userId: user!.uid, email: snap["email"] as? String, password: snap["password"] as? String, userImage: UIImage(named: "userPlaceholder"), firstName: snap["firstName"] as? String, lastName: snap["lastName"] as? String)
            completionHandler(userM)
        })
    }
    
    func deleteUser(completionHandler: @escaping (Error?) -> Void){
        let user = Auth.auth().currentUser
        refDB.child("User").child(user!.uid).removeValue()
        user?.delete { error in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func saveUserImg(image: UIImage, completionHandler: @escaping (Error?) -> Void){
        let user = Auth.auth().currentUser
        let imageData = image.jpegData(compressionQuality: 0)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imageName = "UserImg/\(String(describing: user!.uid)).jpeg"
        self.refStorage.child(imageName).putData(imageData!, metadata: metaData) {(data, error) in
            completionHandler(error)
        }
    }
    
    func getUserImg(completionHandler: @escaping (Data?, Error?) -> Void){
        let user = Auth.auth().currentUser
        
        let imageName = "UserImg/\(String(describing: user!.uid)).jpeg"
        refStorage.child(imageName).getData(maxSize: 1*500*500, completion: {(data, error) in
            completionHandler(data, error)
        })
    }
    
    func savePost (post: PostModel, completionHandler: @escaping (Error?) -> Void){
        let postKey = refDB.child("Posts").childByAutoId().key
        let postDict = ["postId" : postKey!, "userId" : post.userId!, "postBody" : post.postBody!, "date" : post.date!, "timestamp" : post.timestamp as Any] as [String : Any]
        refDB.child("User").child(post.userId!).child("Posts").child(postKey!).setValue(postDict)
        refDB.child("Posts").child(postKey!).setValue(postDict)
            { (error, ref) in
            completionHandler(error)
        }
        
    }
    
    func savePostImg(date: String, image: UIImage, completionHandler: @escaping (Error?) -> Void){
        let user = Auth.auth().currentUser
        let img = image
        let imgData = img.jpegData(compressionQuality: 0)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imgName = "PostImg/\(user!.uid)/\(String(describing: date)).jpeg"
        refStorage.child(imgName).putData(imgData!, metadata: metaData) { (data, error) in
            completionHandler(error)
        }
    }
    
    func getAllConversationsForUser(completionHandler: @escaping ([[String : Any]]?) -> Void){
            let currentUser = Auth.auth().currentUser
            let usersGroup = DispatchGroup()
    //        let componentsUserGroup = DispatchGroup()
            var arrOfUsersWithConv = [[String: Any]]()
            
            refDB.child("User").child(currentUser!.uid).child("Chats").observeSingleEvent(of: .value) { (snapshot) in
                if let conversations = snapshot.value as? [String : Any]{
                    for conversation in conversations {
                        usersGroup.enter()
                        self.refDB.child("User").child(conversation.key).observeSingleEvent(of: .value) { (userSnapshot) in
                            var userDict = [String : Any]()
                            guard let singleUser = userSnapshot.value as? [String : Any] else {
                                return}
                            userDict["firstName"] = singleUser["firstName"] as? String
                            userDict["lastName"] = singleUser["lastName"]
                            userDict["userId"] = singleUser["userId"]
                            self.getUserImgById(id: userDict["userId"] as! String) { (data, error) in
                                if error == nil && !(data == nil){
                                    userDict["userImg"] = UIImage(data: data!) ?? UIImage()
                                }
    //                            if error == nil && data == nil {
    //                                userDict["userImg"] = defaultImg(gender: (singleUser["gender"] as? String)!)
    //                            }
                                arrOfUsersWithConv.append(userDict)
                                usersGroup.leave()
                            }
                        }
                    }
                    usersGroup.notify(queue: .main){
                        completionHandler(arrOfUsersWithConv)
                    }
                }
                
            }
        }
    
    //friends functionality
    //get all friends
    func getAllFriends(completionHandler: @escaping ([UserModel]) -> Void){
         let currentUser = Auth.auth().currentUser
         var friendArr = [UserModel]()
         let friendDispatchGroup = DispatchGroup()
         refDB.child("User").child(currentUser!.uid).child("Friends").observeSingleEvent(of: .value) { (snapshot) in
             if let friends = snapshot.value as? [String : Any] {
                 for friend in friends {
                     friendDispatchGroup.enter()
                    self.refDB.child("User").child(friend.key).observeSingleEvent(of: .value) { (friendSnapshot) in
                         guard let singleFriend = friendSnapshot.value as? [String : Any] else {return}
                         var userM = UserModel(userId: friend.key, email: singleFriend["email"] as? String, password: singleFriend["password"] as? String, userImage: nil, firstName: singleFriend["firstName"] as? String, lastName: singleFriend["lastName"] as? String)
                         self.getUserImgById(id: userM.userId!) { (data, error) in
                             if error == nil && !(data == nil){
                                 userM.userImage = UIImage(data: data!) ?? UIImage()
                             }
                            else {
                                userM.userImage = UIImage(named: "userPlaceholder")
                            }
                             friendArr.append(userM)
                             friendDispatchGroup.leave()
                         }
                     }
                    friendDispatchGroup.notify(queue: .main){
                        completionHandler(friendArr)
                    }
                 }
                 
             }
         }
     }
    
    func addFriend(friendId: String, completionHandler: @escaping (Error?) -> Void) {
           let curUser = Auth.auth().currentUser
        refDB.child("User").child((curUser?.uid)!).child("Friends").child(friendId).updateChildValues([friendId : "friendId"] ){(error, ref) in
               completionHandler(error)
           }
       }
    
    func deleteFriend(friendId: String, completionHandler: @escaping (Error?) -> Void){
        let curUser = Auth.auth().currentUser
        refDB.child("User").child((curUser?.uid)!).child("Friends").child(friendId).removeValue(){(error, ref) in
            completionHandler(error)
        }
    }
    
    
    func getAllMsgsForChat(recepientId: String, completionHandler: @escaping  ([[String : Any]]?) -> Void){
            let uid = Auth.auth().currentUser?.uid
            let chatsGroup = DispatchGroup()
    //        let singlePost = DispatchGroup()
            var chatsArray = [[String : Any]]()

            chatsGroup.enter()
            refDB.child("User").child(uid!).child("Chats").child(recepientId).observeSingleEvent(of: .value) { (snapshot, error) in
                if error != nil {
                    print(error ?? "Error happened fetching chats")
                } else {
                    guard let records = snapshot.value as? [String : Any] else { return }
                    for record in records {
                        let cid = record.key
                        let chat = records[cid] as! [String : Any]
                        var chatDict = [String: Any]()
                        let chatM = MessageModel(timestamp: chat["timestamp"] as? Double, recepientId: chat["recepientId"] as? String, date: chat["date"] as? String, msgBody: chat["msgBody"] as? String, status: chat["status"] as? String)
                        chatDict["timestamp"] = chat["timestamp"] as? Double
                        chatDict["msgModel"] = chatM
                        chatsArray.append(chatDict)
                    }
                }
                chatsGroup.leave()
            }
            chatsGroup.notify(queue: .main){
                completionHandler(chatsArray)
            }
        }
    
        func sendMessage(msgModel : MessageModel, completionHandler: @escaping (Error?) -> Void){
            let uid = Auth.auth().currentUser?.uid
    //        let messageSent = DispatchGroup()
            let sendMessagesGroup = DispatchGroup()
            let messageId = refDB.child("Users").child(uid!).child("Chats").child(msgModel.recepientId!).childByAutoId().key
            let senderDict = ["timestamp": msgModel.timestamp!, "recepientId": msgModel.recepientId!, "date" : msgModel.date!, "msgBody": msgModel.msgBody!, "status": msgModel.status!] as [String : Any]
            
            let recepientDict = ["timestamp": msgModel.timestamp!, "recepientId": msgModel.recepientId!, "date" : msgModel.date!, "msgBody": msgModel.msgBody!, "status": "received"] as [String : Any]
            refDB.child("User").child(uid!).child("Chats").child(msgModel.recepientId!).child(messageId!).setValue(senderDict){(error, ref) in
                if error != nil {
                    print("Succesfully sent a message")
                } else {
                    completionHandler(error)
                }
            }
            refDB.child("User").child(msgModel.recepientId!).child("Chats").child(uid!).child(messageId!).setValue(recepientDict){(error, ref) in
                if error != nil {
                    print("Succesfully sent a message")
                } else {
                    completionHandler(error)
                }
            }

        }
        func getAllPostsByUserId(id: String, completionHandler: @escaping ([PostModel]?) -> Void){
            let postGroup = DispatchGroup()
            let imageGroup = DispatchGroup()

            postGroup.enter()
            refDB.child("Posts").observeSingleEvent(of: .value) { (snapshot) in
                var arrPosts = [PostModel]()
                if let posts = snapshot.value as? [String : Any]{
                    for record in posts {
                        let pid = record.key
                        let post = posts[pid] as! [String : Any]
                        var postM = PostModel(timestamp: post["timestamp"] as? Double, userId: post["userId"] as? String, postBody: post["postBody"] as? String, date: post["date"] as? String, postImage: nil, postId: pid)
                        imageGroup.enter()
                        self.getPostImg(userId: postM.userId!, date: postM.date!) { (data, error) in
                            if error == nil && !(data == nil) {
                                postM.postImage = UIImage(data: data!)
                            }
                           if postM.userId == id {
                               arrPosts.append(postM)
                           }
                        imageGroup.leave()
                        }
                    }
                    imageGroup.notify(queue: .main){
                        postGroup.leave()
                    }
                    postGroup.notify(queue: .main){
                        completionHandler(arrPosts)
                    }
                }
            }
        }
        
 
    
    
    
}
