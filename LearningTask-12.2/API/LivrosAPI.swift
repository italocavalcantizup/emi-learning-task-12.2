//
//  LivrosAPI.swift
//  LearningTask-12.2
//
//  Created by rafael.rollo on 03/08/2022.
//

import Foundation

class LivrosAPI {
    
    private var httpRequest: HTTPRequest
    
    init(httpRequest: HTTPRequest) {
        self.httpRequest = httpRequest
    }
    
    func getAllBooks(forAuthorId authorId: Int? = nil,
                     completionHandler: @escaping (Result<[Livro], Error>) -> Void) {
        
        let id = authorId != nil ? "/\(String(describing: authorId))" : ""
        let endpoint = Endpoint(path: "/api\(id)/book")
        
        httpRequest.execute(endpoint: endpoint) { (result: Result<[Livro], NetworkError>) in
            switch result {
            case .success(let books):
                DispatchQueue.main.async {
                    completionHandler(.success(books))
                }
            case .failure(let error):
                debugPrint(error)
                DispatchQueue.main.async {
                    completionHandler(.failure(.executionFailed(error)))
                }
            }
        }
    }
    
    func registerBook(_ book: Livro,
                      completionHandler: @escaping (Result<Livro, Error>) -> Void) {
        let endpoint = Endpoint(path: "/api/book")
        httpRequest.execute(endpoint: endpoint, method: .post, body: book.converterParaLivroDTO()) { (result: Result<Livro, NetworkError>) in
            switch result {
            case .success(let livro):
                DispatchQueue.main.async {
                    completionHandler(.success(livro))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completionHandler(.failure(.executionFailed(error)))
                }
            }
        }
    }
}

extension LivrosAPI {
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

fileprivate extension Livro {
    struct Request: Encodable {
        var authorId: Int
        var comboPrice: Decimal
        var coverImagePath: String
        var description: String
        var eBookPrice: Decimal
        var hardcoverPrice: Decimal
        var isbn: String
        var numberOfPages: Int
        var publicationDate: String
        var subtitle: String
        var title: String
    }
    
    func converterParaLivroDTO() -> Encodable {
        return Request(
            authorId: self.autor.id ?? 0,
            comboPrice: self.precos.first(where: { $0.tipoDeLivro == .combo})?.valor ?? 0,
            coverImagePath: String(describing: self.imagemDeCapaURI),
            description: self.descricao,
            eBookPrice: self.precos.first(where: { $0.tipoDeLivro == .ebook })?.valor ?? 0,
            hardcoverPrice: self.precos.first(where: { $0.tipoDeLivro == .impresso })?.valor ?? 0,
            isbn: self.isbn,
            numberOfPages: self.numeroDePaginas,
            publicationDate: self.dataPublicacao,
            subtitle: self.subtitulo,
            title: self.titulo)
    }
}
