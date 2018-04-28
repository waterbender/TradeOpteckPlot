//
//  WebAndFilesClient.swift
//  TradeOpteck
//
//  Created by Yevgenii Pasko on 4/26/18.
//  Copyright © 2018 Yevgenii Pasko. All rights reserved.
//

import UIKit

class WebAndFilesClient {

    func getRequestList(urlString: String, completion: @escaping (Data) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("Error unwrapping URL"); return }
        guard let cachePolicy = URLRequest.CachePolicy(rawValue: 5) else {
            print("Error unwrapping cache"); return }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 50)
        request.httpMethod = "GET"
        performUrlRequest(request: request, completion: completion)
    }
    
    func postRequest(urlString:String, parameters: [Any], completion: @escaping (Data) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("Error unwrapping URL"); return }
        guard let cachePolicy = URLRequest.CachePolicy(rawValue: 5) else {
            print("Error unwrapping cache"); return }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: 40)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        do {
            let data = try JSONSerialization.data(withJSONObject: parameters, options: [])
            request.httpBody = data
        } catch {
            print("Error: cannot create JSON from todo")
            return
        }
        performUrlRequest(request: request, completion: completion)
    }
    
    private func performUrlRequest(request: URLRequest, completion: @escaping (Data) -> Void) {
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            
            //5 - unwrap our returned data
            guard let unwrappedData = data else { print("Error getting data"); return }
            completion(unwrappedData)
        }
        //10 -
        dataTask.resume()
    }
}
