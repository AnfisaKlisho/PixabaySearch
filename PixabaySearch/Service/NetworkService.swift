//
//  NetworkService.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 09.12.2020.
//

import UIKit

class NetworkService{
    private init(){} //we can initialize this class only inside this class
    
    static let shared = NetworkService() //constant that will be used in view controller to interact with network service
    
    private let apiKey = "19457046-191b2db90d065b0533f76e410"
    
    private var baseUrlComponent: URLComponents{
        var _urlComps = URLComponents(string: "https://pixabay.com")!
        _urlComps.path = "/api"
        _urlComps.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        return _urlComps
    }
    
    //MARK:- Load Image
    func loadImage(from url: URL?, completion: @escaping (UIImage?) -> Void) {
            guard let url = url else {
                completion(nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                DispatchQueue.main.async {
                    if let data = data {
                        completion(UIImage(data: data))
                    } else {
                        completion(nil)
                    }
                }
                
            }.resume()
            
        }


    
    //MARK:- Fetch Images
    func fetchImages(amount: Int, page: Int, completion: @escaping (Result<[ImageInfo], SessionError>) -> Void){
        var urlComps = baseUrlComponent
        urlComps.queryItems? += [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(amount)"),
            URLQueryItem(name: "editors_choice", value: "\(true)")
            
        ]
        
        guard let url = urlComps.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.other(error)))
                }
                return
            }
            
            let response = response as! HTTPURLResponse
            guard let data = data, response.statusCode == 200 else{
                DispatchQueue.main.async {
                    completion(.failure(.serverError(response.statusCode)))
                }
                return
            }
            
            do {
                let serverResponse = try JSONDecoder().decode(ServerResponse<ImageInfo>.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(serverResponse.hits))
                }
            }
            
            catch let decodingError{
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(decodingError)))
                }
            }
            
        }.resume()
    }
    
}
