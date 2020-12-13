//
//  ServerResponse.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 14.12.2020.
//

import Foundation

struct ServerResponse<T: Decodable>: Decodable {
    var hits: [T]
}
