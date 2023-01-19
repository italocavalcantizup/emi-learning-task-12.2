//
//  APIError.swift
//  LearningTask-12.2
//
//  Created by Italo cavalcanti on 11/01/23.
//

import Foundation

enum NetworkError: Swift.Error, LocalizedError {
    
    case unableToRequest(Swift.Error)
    case requestFailed(statusCode: Int)
    case invalidData(Swift.Error)
        
    var errorDescription: String? {
            switch self {
            case .unableToRequest(let error):
                return "Unable to perform the request. \(error.localizedDescription)"
            case .requestFailed(let statusCode):
                return "Request failed. \(statusCode)"
            case .invalidData(let error):
                return "Unable to parse the request data. \(error.localizedDescription)"
            }
        }
}
