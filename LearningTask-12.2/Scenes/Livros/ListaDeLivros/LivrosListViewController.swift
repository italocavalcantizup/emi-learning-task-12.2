//
//  LivrosListViewController.swift
//  LearningTask-12.2
//
//  Created by rafael.rollo on 03/08/2022.
//

import UIKit

class LivrosListViewController: UICollectionViewController {
    
    private enum Segues: String {
        case verFormNovoLivro = "verFormNovoLivroSegue"
        case verDetalhesDoLivro = "verDetalhesDoLivroSegue"
    }

    var livrosAPI: LivrosAPI?
    
    var livros: [Livro] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        
        carregaLivros()
    }
    
    func carregaLivros() {
        guard let livrosAPI = livrosAPI else { return }
        livrosAPI.getAllBooks { [weak self] result in
            switch result {
            case .success(let books):
                self?.livros = books
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier,
              let expectedSegue = LivrosListViewController.Segues(rawValue: segueId) else { return }
        
        switch expectedSegue {
        case .verDetalhesDoLivro:
            prepareForDetalhesDoLivro(segue, sender)
        case .verFormNovoLivro:
            prepareForFormNovoLivro(segue, sender)
        }
    }
    
    private func prepareForDetalhesDoLivro(_ segue: UIStoryboardSegue,_ sender: Any?) {
        guard let celula = sender as? LivroCollectionViewCell,
              let controller = segue.destination as? LivroViewController else {
            fatalError("Não foi possível executar segue \(segue.identifier!)")
        }
        
        controller.livro = celula.livro
    }
    
    private func prepareForFormNovoLivro(_ segue: UIStoryboardSegue,_ sender: Any?) {
        guard let controller = segue.destination as? NovoLivroViewController else {
            fatalError("Não foi possível executar a segue: \(segue.identifier!)")
        }
        controller.delegate = self
        controller.livrosAPI = LivrosAPI(httpRequest: HTTPRequest())
    }

}

// MARK: - UICollectionViewDataSource implementations
extension LivrosListViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return livros.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let celula = collectionView.dequeueReusableCell(withReuseIdentifier: "LivroCollectionViewCell", for: indexPath) as? LivroCollectionViewCell else {
            fatalError("Não foi possível obter célula para o item na coleção de livros")
        }
        
        celula.livro = livros[indexPath.row]
        return celula
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return configureReusableHeaderView(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
            
        default:
            fatalError("Tipo de view não suportado")
        }
    }
    
    private func configureReusableHeaderView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LivroSectionHeaderView", for: indexPath) as? LivroSectionHeaderView else {
            fatalError("Não foi possível recuperar view para o titulo da seção")
        }
        
        headerView.titulo = "Todos os Livros"
        return headerView
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout implementations
extension LivrosListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("É esperado que a collectionView de livros trabalhe com layout baseado em FlowLayout.")
        }
      
        let margens = flowLayout.sectionInset
        let espacamento = flowLayout.minimumInteritemSpacing
        
        let itensPorLinha: CGFloat = 2
        let alturaDoLabel: CGFloat = 48
        
        let areaUtil = collectionView.bounds.width - ( margens.left + margens.right ) - espacamento * ( itensPorLinha - 1 )
        
        let largura = areaUtil / itensPorLinha
        let altura = largura * 1.41 + alturaDoLabel
        
        return CGSize(width: largura, height: altura)
    }
    
}

extension LivrosListViewController: NovoLivroViewControllerDelegate {
    
    func novoLivroViewController(_ viewController: NovoLivroViewController, adicionou livro: Livro) {
        livros.append(livro)
    }
}
