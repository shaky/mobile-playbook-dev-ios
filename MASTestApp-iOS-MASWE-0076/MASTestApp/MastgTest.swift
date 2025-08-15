//
//  MastgTest.swift
//  MASTestApp
//
//  Created by Charlie on 28.04.24.
//

import SwiftUI
import Alamofire

struct MastgTest {
    static func mastgTest(completion: @escaping (String) -> Void) {
        let value = "Random Number: \(Int.random(in: 1...100))"
        completion(value)
        

        // Make a GET request to github.com
        AF.request("https://github.com").response { response in
            switch response.result {
            case .success(let data):
                if let data = data, let html = String(data: data, encoding: .utf8) {
                    print("Response HTML: \(html)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }


        
    }
    
}
