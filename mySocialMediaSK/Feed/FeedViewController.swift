//
//  FeedViewController.swift
//  mySocialMediaSK
//
//  Created by Scott Kerkove on 3/29/20.
//  Copyright © 2020 Scott Kerkove. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase




class FeedViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var feedVM = FeedViewModel()
    
    @IBOutlet weak var FeedCollectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getPosts()
    }

    @objc func getPosts(){
       
        feedVM.getPosts { (_) in
            DispatchQueue.main.async {
                
                self.FeedCollectionView.reloadData()
            }
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedVM.numberOfRows()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FeedCollectionViewCell
        
        guard indexPath.row < feedVM.numberOfRows() else { return FeedCollectionViewCell()}
        
        feedVM.setInfoForCell(index: indexPath.row) { (both, image, body) in
            if both && !image && !body {
                cell.updateCell(userImg: self.feedVM.userImg!, postImg: self.feedVM.postImg!, userName: self.feedVM.userName!, postBody: self.feedVM.postBody!, date: self.feedVM.date!)
            }
            if !both && image && !body {
                cell.updateCellWOText(userImg: self.feedVM.userImg!, postImg: self.feedVM.postImg!, userName: self.feedVM.userName!, date: self.feedVM.date!)
            }
            if !both && !image && body {
                cell.updateCellWOImg(userImg: self.feedVM.userImg!, userName: self.feedVM.userName!, postBody: self.feedVM.postBody!, date: self.feedVM.date!)
            }
        }
        return cell
    }

    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
//        feedVM.getPostAndUserInfoToPass(index: indexPath.row)
//        
//        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DetailPostViewController") as! DetailPostViewController
//        vc.imgPost = feedVM.postImg
//        vc.imgUser = feedVM.userImg
//        vc.userName = feedVM.userName
//        vc.date = feedVM.date
//        vc.postBody = feedVM.postBody
//        vc.userId = feedVM.userId
//        vc.postId = feedVM.postId
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true, completion: nil)
//        
//    }
}
