//
//  DatabaseRequests.swift
//  CareIt
//
//  Created by William Londergan (student LM) on 1/16/19.
//  Copyright © 2019 Jason Kozarsky (student LM). All rights reserved.
//

import Foundation

class DatabaseRequests {
    //doesn't work
    var result: Food?
    var barcodeString: String
    var currentlyProcessing = false
    
    func request(beforeLoading: () -> Void, afterLoading: @escaping () -> Void) {
        beforeLoading()
        currentlyProcessing = true
       
        let urlString = "https://api.nal.usda.gov/ndb/search/?format=json&q=\(barcodeString)&sort=n&max=25&offset=0&api_key=QeUnhmFwm0AZn3JpYHBwTd1cwx5LMk1zbDwGhgDJ"
    
        guard let url = URL(string: urlString) else {print("url 1 error");self.currentlyProcessing = false; DispatchQueue.main.async(execute: afterLoading); return}
      
        URLSession.shared.dataTask(with: url) { (data, request, error) in
            guard let data = data else { print("request 1 error"); self.currentlyProcessing = false; DispatchQueue.main.async(execute: afterLoading); return}
            
            do{
                
                let res = try JSONDecoder().decode(FoodIDDatabaseRequest.self, from: data)
              
    
                let ndbno = res.list.item[0].ndbno
                let ndbString = "https://api.nal.usda.gov/ndb/V2/reports?ndbno=\(ndbno)&type=f&format=json&api_key=QeUnhmFwm0AZn3JpYHBwTd1cwx5LMk1zbDwGhgDJ"
    
                guard let url = URL(string: ndbString) else {print("url 2 error"); self.currentlyProcessing = false;return}
    
                //second request inside the first
                URLSession.shared.dataTask(with: url) {
                    (data, request, error) in
                    guard let data = data else {print("data 2 error"); self.currentlyProcessing = false; return}
                    do {
                        let res = try JSONDecoder().decode(NDBDatabaseRequest.self, from: data)
                        self.result = res.foods.first?.food
                        DispatchQueue.main.async(execute: afterLoading)
                    } catch {print("decoding error"); self.currentlyProcessing = false; DispatchQueue.main.async(execute: afterLoading); return}
    
    
                }.resume()
    
            } catch {print("generic error"); self.currentlyProcessing = false; DispatchQueue.main.async(execute: afterLoading); return}
    
            }.resume()
        
        }
    
    init(barcodeString: String) {
        self.barcodeString = barcodeString
    }

}
