//
//  ImageInfo.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 13.12.2020.
//

import Foundation

struct ImageInfo: Decodable{
    var id: Int
    var previewURL: URL?
    var webformatURL: URL?
    var views: Int
    var downloads: Int
    var likes: Int
    var user: String
    var userImageURL: URL?
    
}
