//
//  DataProviderModel.swift
//  ITSPartner
//
//  Created by Расул Караев on 7/10/20.
//  Copyright © 2020 Расул Караев. All rights reserved.
//

import Foundation

class DataProviderModel {
    let semaphore = DispatchSemaphore(value: 0)
    // Data obtained from API.
    var data = [[String: Any]]()
    
    func getMainData() {
        let url = URL(string: "https://my.api.mockaroo.com/persons.json?key=f43efc60")
        guard url != nil else { return }
        URLSession.shared.dataTask(with: url!) { (Data, URLResponse, Error) in
            defer { self.semaphore.signal() }
            do {
                var jsonData = try JSONSerialization.jsonObject(with: Data!, options: []) as! [[String: Any]]
                let dataWithAges = self.calcAge(jsonData: &jsonData)
                self.data = dataWithAges
                UserDefaults.standard.set(dataWithAges, forKey: "mainData")
            } catch {
                print(Error ?? "Something get wrong")
            }
        }.resume()
        self.semaphore.wait()
    }
    
    // Calculate age based on dateOfBirtdh value.
    func calcAge(jsonData: inout [[String: Any]]) -> [[String: Any]] {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM/dd/yyyy"
        
        var iteration = -1
        
        for item in jsonData {
            iteration += 1
            let birthday = item["dateOfBirtdh"] as! String
            let birthdayDate = dateFormater.date(from: birthday)
            let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
            let now = Date()
            let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
            let age = calcAge.year
            jsonData[iteration]["age"] = age
        }

        return jsonData
    }
}
