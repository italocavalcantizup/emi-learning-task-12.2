//
//  HTTPRequest.swift
//  LearningTask-12.2
//
//  Created by Italo cavalcanti on 11/01/23.
//

import Foundation

protocol APIResource {
    var endpoint: Endpoint { get }
}



enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

extension HTTPURLResponse {
    var inSuccessRange: Bool {
        return (200..<300).contains(statusCode)
    }
}

typealias HTTPHeaders = [String : String]

class HTTPRequest {
    
    private let session: URLSession
    private var dataTask: URLSessionDataTask?
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication = .init(),
         session: URLSession = URLSession.shared) {
        self.userAuthentication = userAuthentication
        self.session = session
    }
    
    func execute<T: Codable>(endpoint: Endpoint,
                             method httpMethod: HTTPMethod = .get,
                             body encodable: Encodable? = nil,
                             headers httpHeaders: HTTPHeaders? = nil,
                             decoder: JSONDecoder = .init(),
                             encoder: JSONEncoder = .init(),
                             completionHandler: @escaping (Result<T, NetworkError>) -> Void) {
        dataTask?.cancel()
        
        guard let uri = endpoint.uri else {
            preconditionFailure("Não fois possível construir a URI")
        }
        
        guard let authentication = userAuthentication.get() else {
            preconditionFailure("Estado ilegal para a aplicação: Usuário deve estar logado")
        }
        
        var request = URLRequest(url: uri)
        request.httpMethod = httpMethod.rawValue
        
        if let httpHeaders = httpHeaders {
            httpHeaders.forEach { (header, value) in request.setValue(value, forHTTPHeaderField: header)}
        }
        
        if let encodable = encodable {
            do {
                let data = try encoder.encode(encodable)
                
                request.httpBody = data
                request.setValue("application/json", forHTTPHeaderField: "Content-type")
                request.setValue(authentication.value, forHTTPHeaderField: "Authorization")
            } catch let error {
                debugPrint(error)
                    let contextError = NetworkError.invalidData(error)
                    completionHandler(.failure(contextError))
                    return
            }
        }
        
        dataTask = session.dataTask(with: request) { [weak self] data, response, error in
            defer {
                self?.dataTask = nil
            }
            
            let result = Result(value: data, error: error)
                .mapError { error in
                    return NetworkError.unableToRequest(error)
                }
                .flatMap { data in
                    return Result(catching: { try decoder.decode(T.self, from: data) })
                }
                .flatMapError { error in
                    if let error = error as? NetworkError {
                        return Result.failure(error)
                    }
                    
                    if let response = response as? HTTPURLResponse, !response.inSuccessRange {
                        return Result.failure(.requestFailed(statusCode: response.statusCode))
                    }
                    
                    return Result.failure(.invalidData(error))
                }
            
            completionHandler(result)
        }
        
        dataTask?.resume()
    }
}
