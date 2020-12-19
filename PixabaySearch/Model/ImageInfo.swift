//
//  ImageInfo.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 13.12.2020.
//

import Foundation

struct ImageInfo: Decodable{
    var id: Int
    var webformatURL: URL
    var views: Int
    var comments: Int
    var likes: Int
    var favorites: Int
    var user: String?
    var userImageURL: String
    
}
