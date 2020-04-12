//
//  NetworkManager.swift
//  WhatFlower
//
//  Created by Faisal Babkoor on 3/31/20.
//  Copyright © 2020 Faisal Babkoor. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SDWebImage

class NetworkManager {
    
    static let shared = NetworkManager()
    private let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
    private init() {}
    
    func getInfo(flowerName: String, completionHandler: @escaping (Result<Flower, Error>) -> Void) {
        guard let url = URL(string: wikipediaURl) else { return }
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "redirects" : "1",
            "pithumbsize" : "500",
            "indexpageids" : ""
        ]
        
        AF.request(url, method: .get, parameters: parameters).responseJSON { response in
            
            let result = response.result
            switch result {
            case .success(let data):
                let flowerJSON = JSON(data)
                let pageid = flowerJSON["query"]["pageids"][0].stringValue
                let flowerName = flowerJSON["query"]["pages"][pageid]["title"].stringValue
                let flowerDescription = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                let flowerImageURL = flowerJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue
                guard let ImageURL = URL(string: flowerImageURL) else { return }
                let flower = Flower(name: flowerName, flowerDescription: flowerDescription, image: ImageURL)
                completionHandler(.success(flower))
            case .failure(let err):
                print(err)
                completionHandler(.failure(err))
            }
        }
    }
}
