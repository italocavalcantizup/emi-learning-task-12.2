//
//  Livro.swift
//  LearningTask-12.2
//
//  Created by rafael.rollo on 03/08/2022.
//

import Foundation

enum TipoDeLivro: String, CaseIterable, Codable {
    case ebook = "EBOOK"
    case impresso = "HARDCOVER"
    case combo = "COMBO"
    
    var index: Int {
        switch self {
        case .ebook:
            return 0
        case .impresso:
            return 1
        case .combo:
            return 2
        }
    }
    
    var titulo: String {
        switch self {
        case .ebook:
            return "E-book"
        case .impresso:
            return "Impresso"
        case .combo:
            return "E-book + impresso"
        }
    }
}

struct Preco: Codable {
    let valor: Decimal
    let tipoDeLivro: TipoDeLivro
    
    enum CodingKeys: String, CodingKey {
        case valor = "value"
        case tipoDeLivro = "bookType"
    }
}

struct Livro: Codable {
    let id: Int?
    let titulo: String
    let subtitulo: String
    let imagemDeCapaURI: URL
    let descricao: String
    let autor: Autor
    let precos: [Preco]
    let isbn: String
    let dataPublicacao: String
    let numeroDePaginas: Int
    
    init(id: Int? = nil, titulo: String, subtitulo: String, imagemDeCapaURI: URL, descricao: String, autor: Autor, precos: [Preco], isbn: String, dataPublicacao: String, numeroDePaginas: Int) {
        self.id = id
        self.titulo = titulo
        self.subtitulo = subtitulo
        self.imagemDeCapaURI = imagemDeCapaURI
        self.descricao = descricao
        self.autor = autor
        self.precos = precos
        self.isbn = isbn
        self.dataPublicacao = dataPublicacao
        self.numeroDePaginas = numeroDePaginas
    }
    
    enum CodingKeys: String, CodingKey {
        case id, isbn
        case titulo = "title"
        case subtitulo = "subtitle"
        case imagemDeCapaURI = "coverImagePath"
        case autor = "author"
        case precos = "prices"
        case descricao = "description"
        case dataPublicacao = "publicationDate"
        case numeroDePaginas = "numberOfPages"
    }
}

extension Livro {
    struct Response: Decodable {
        let results: [Livro]
    }
}


