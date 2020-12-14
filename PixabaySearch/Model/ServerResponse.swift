//
//  ServerResponse.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 14.12.2020.
//

import Foundation

struct ServerResponse<Object: Decodable>: Decodable {
    var hits: [Object]
}
