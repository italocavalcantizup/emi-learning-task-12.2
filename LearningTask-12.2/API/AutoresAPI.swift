//
//  AutoresAPI.swift
//  LearningTask-12.2
//
//  Created by rafael.rollo on 03/08/2022.
//

import Foundation

/**
 Componente cliente da api de autores da casa do código.
 Implementação atual apenas simula um carregamento.
 Integrações com serviços HTTP estão fora do escopo da atividade atual e será tema mais a frente
 */
class AutoresAPI {
    
    private var httpRequest: HTTPRequest
    private var userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication = .init(),
         httpRequest: HTTPRequest) {
        self.userAuthentication = userAuthentication
        self.httpRequest = httpRequest
    }
    
    func getAllAuthors(completionHandler: @escaping (Result<[Autor], Error>) -> Void) {
        
        let endpoint = Endpoint(path: "/api/author")
        httpRequest.execute(endpoint: endpoint) { (result: Result<[Autor], NetworkError>) in
            switch result {
            case .success(let autores):
                DispatchQueue.main.async {
                    completionHandler(.success(autores))
                }
            case .failure(let error):
                debugPrint(error)
                DispatchQueue.main.async {
                    completionHandler(.failure(.executionFailed(error)))
                }
            }
        }
    }

    func registerNew(_ autor: Autor,
                     completionHandler: @escaping (Result<Autor, Error>) -> Void) {
        
        let endpoint = Endpoint(path: "/api/author")
        httpRequest.execute(endpoint: endpoint, method: .post, body: autor) { (result: Result<Autor, NetworkError>) in
            switch result {
            case .success(let autor):
                DispatchQueue.main.async {
                    completionHandler(.success(autor))
                }
            case .failure(let error):
                debugPrint(error)
                DispatchQueue.main.async {
                    completionHandler(.failure(.executionFailed(error)))
                }
            }
        }
    }
}

extension AutoresAPI {
    enum Error: Swift.Error, LocalizedError {
        case executionFailed(NetworkError)
        
        var errorDescription: String? {
            switch self {
            case .executionFailed(let error):
                return error.localizedDescription
            }
        }
    }
}
