//
//  SessionError.swift
//  PixabaySearch
//
//  Created by Anfisa Klisho on 14.12.2020.
//

import Foundation

enum SessionError: Error{
    case invalidURL, decodingError(Error), serverError(_ statusCode: Int), other(Error)
    
    var localizedDescription: String{
        switch self {
        case .invalidURL:
            return "Invalid URL-address"
        case let .decodingError(error):
            return error.localizedDescription
            
        case let .serverError(statusCode):
            return "Unable to connect with server (\(statusCode))"
        case let .other(error):
            return error.localizedDescription
        }
    }
}
