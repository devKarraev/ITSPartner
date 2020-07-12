//
//  AllInfoCollectionViewController.swift
//  ITSPartner
//
//  Created by Расул Караев on 7/11/20.
//  Copyright © 2020 Расул Караев. All rights reserved.
//

import UIKit

private let reuseIdentifier = "AllInfoCell"

class AllInfoCollectionViewController: UICollectionViewController {

    var firstName = String(),
        lastName = String(),
        id = String(),
        email = String(),
        gender = String(),
        dateOfBirth = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissCurrentVC(sender: )))
    }
    
    @objc func dismissCurrentVC(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! AllInfoCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = #colorLiteral(red: 0.6635413766, green: 0.915610075, blue: 0.9694051147, alpha: 1)
        cell.name.sizeToFit()
        cell.email.sizeToFit()
        cell.name.text = "Name: " + self.firstName + " " + self.lastName
        cell.id.text = "Id: " + self.id
        cell.email.text = "Email: " + self.email
        cell.gender.text = "Gender: " + self.gender
        cell.dateOfBirth.text = "Date of birth: " + self.dateOfBirth
 
        return cell
    }
}

extension AllInfoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/1.2, height: 300)
     }

     func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 50, left: 20, bottom: 20, right: 20)
    }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return CGFloat(20)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return CGFloat(20)
     }
}
