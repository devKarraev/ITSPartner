//
//  CollectionViewController.swift
//  ITSPartner
//
//  Created by Расул Караев on 7/10/20.
//  Copyright © 2020 Расул Караев. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CollectionCell"

class CollectionViewController: UICollectionViewController {

    let dataProvider = DataProviderModel(),
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert),
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))

        // All data from API.
    var mainData = [[String: Any]](),
    
        // Number of items in UICollectionView.
        countNumber: Int = 0,
    
        // Active segment of UISegmentedConrol.
        selectedSegment: String = "All",
    
        // Check if refresh button tapped.
        isRefreshButtonTappped: Bool = false,
    
        // Current value of filter button.
        filterByAgeValue: String = "up",
    
        // Check if value of filter by age button changed.
        isFilterByAgeChanged: Bool = false,
    
        //Casted data from API
        castedData = [[String: Any]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: filterByAgeValue), style: .done, target: self, action: #selector(filterByAge(sender:)))
        self.getData()
    }
    
    // Filter main data by age.
    @objc func filterByAge(sender: UIBarButtonItem) {
        if filterByAgeValue == "up" {
            filterByAgeValue = "down"
            navigationItem.leftBarButtonItem?.image = UIImage(named: filterByAgeValue)
        } else {
            filterByAgeValue = "up"
            navigationItem.leftBarButtonItem?.image = UIImage(named: filterByAgeValue)
        }
        self.createLoadingAlert(closure: {
            self.isFilterByAgeChanged = true
            self.filterCurrentData(segment: self.selectedSegment, filterByAge: self.filterByAgeValue)
            self.collectionView.reloadData()
            self.isFilterByAgeChanged = false
        })
    }
    
    // Get main data from API.
    func getData() {
        self.createLoadingAlert {
            self.dataProvider.getMainData()
            self.mainData = self.dataProvider.data as! [[String: Any]]
            self.collectionView.reloadData()
        }
    }

    // Get newest data from API.
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "up")
        self.mainData.removeAll()
        self.castedData.removeAll()
        self.isRefreshButtonTappped = true
        self.filterCurrentData(segment: self.selectedSegment, filterByAge: self.filterByAgeValue)
        self.isRefreshButtonTappped = false
        getData()
        self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        self.collectionView.reloadData()
    }
    
    // Change displaying data in UICollectionView based on changing of UISegmentedControl value.
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSegment = "All"
        case 1:
            selectedSegment = "Male"
        default:
            selectedSegment = "Female"
        }
        self.filterCurrentData(segment: self.selectedSegment, filterByAge: self.filterByAgeValue)
        self.collectionView.reloadData()
    }
    
    // Filter main data based on current UISegmentedControl value and value of filterByAge value.
    func filterCurrentData(segment: String, filterByAge: String) {
        if self.castedData.count == 0 {
            self.castedData = UserDefaults.standard.array(forKey: "test")! as! [[String: Any]]
        }
        
        if isFilterByAgeChanged {
            var filteredData = [[String: Any]]()
            if filterByAge == "up" {
                filteredData = castedData.sorted(by: {
                    let firstAge = $0["age"] as! Int,
                        secondAge = $1["age"] as! Int
                    return firstAge < secondAge
                })
            } else {
                filteredData = castedData.sorted(by: {
                    let firstAge = $0["age"] as! Int,
                        secondAge = $1["age"] as! Int
                    return firstAge > secondAge
                })
            }
            self.castedData = filteredData
        }
        
        self.mainData.removeAll()
        
        if selectedSegment == "All" {
            self.mainData = castedData
        } else {
            for item in castedData {
                guard item["gender"] as! String == selectedSegment else { continue }
                self.mainData.append(item)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if self.mainData.count > 0 {
            self.countNumber = self.mainData.count
        }
        
        return self.countNumber
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = #colorLiteral(red: 0.6635413766, green: 0.915610075, blue: 0.9694051147, alpha: 1)
        cell.name.text = "Name: " + String("\(self.mainData[indexPath.row]["first_name"]!)") + " " + String("\(self.mainData[indexPath.row]["last_name"]!)")
        cell.gender.text = "Gender: " + String("\(self.mainData[indexPath.row]["gender"]!)")
        cell.age.text = "Age: " + String("\(self.mainData[indexPath.row]["age"]!)")
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(withIdentifier: "AllInfoCollectionViewController") as! AllInfoCollectionViewController
        let navController = UINavigationController(rootViewController: controller)
        
        controller.navigationItem.title = String("\(self.mainData[indexPath.row]["first_name"]!)") + " " + String("\(self.mainData[indexPath.row]["last_name"]!)")
        controller.firstName = String("\(self.mainData[indexPath.row]["first_name"]!)")
        controller.lastName = String("\(self.mainData[indexPath.row]["last_name"]!)")
        controller.id = String("\(self.mainData[indexPath.row]["id"]!)")
        controller.email = String("\(self.mainData[indexPath.row]["email"]!)")
        controller.gender = String("\(self.mainData[indexPath.row]["gender"]!)")
        controller.dateOfBirth = String("\(self.mainData[indexPath.row]["dateOfBirtdh"]!)")
        
        self.present(navController, animated: true, completion: nil)
    }
    
    // Display loading alert while process running.
    func createLoadingAlert(closure: (() -> Void)? = nil) {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        self.present(alert, animated: true, completion: closure)
        self.dismiss(animated: true, completion: nil)
    }
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/1.2, height: 100)
     }

     func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return CGFloat(20)
     }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return CGFloat(20)
     }
}
