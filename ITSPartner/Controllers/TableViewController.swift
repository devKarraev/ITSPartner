//
//  TableViewController.swift
//  ITSPartner
//
//  Created by Расул Караев on 7/10/20.
//  Copyright © 2020 Расул Караев. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

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
        self.mainData = UserDefaults.standard.array(forKey: "test")! as! [[String: Any]]
        self.tableView.reloadData()
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
            self.tableView.reloadData()
            self.isFilterByAgeChanged = false
        })
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.mainData.count > 0 {
            self.countNumber = self.mainData.count
        }
        
        return self.countNumber
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0;
        cell.textLabel?.lineBreakMode = .byWordWrapping;
        
        // Configure the cell...
        cell.textLabel?.text = String(
            """
            Name: \(self.mainData[indexPath.row]["first_name"]!) \(self.mainData[indexPath.row]["last_name"]!)
            Gender: \(self.mainData[indexPath.row]["gender"]!)
            Age: \(self.mainData[indexPath.row]["age"]!)
            """
        )
        return cell
    }
    
    // Get newest data from API.
    @IBAction func refreshData(_ sender: UIBarButtonItem) {
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "up")
        self.mainData.removeAll()
        self.castedData.removeAll()
        self.isRefreshButtonTappped = true
        self.filterCurrentData(segment: self.selectedSegment, filterByAge: self.filterByAgeValue)
        self.isRefreshButtonTappped = false
        self.createLoadingAlert {
            self.dataProvider.getMainData()
            self.mainData = self.dataProvider.data as! [[String: Any]]
            self.tableView.reloadData()
        }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        self.tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
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
}
