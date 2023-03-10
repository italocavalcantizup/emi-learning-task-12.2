//
//  LivroViewController.swift
//  LearningTask-12.2
//
//  Created by rafael.rollo on 03/08/2022.
//

import UIKit

class LivroViewController: UIViewController {

    @IBOutlet private weak var tituloLabel: UILabel!
    @IBOutlet private weak var subtituloLabel: UILabel!
    @IBOutlet private weak var nomeDoAutorLabel: UILabel!
    @IBOutlet private weak var capaImageView: UIImageView!
    @IBOutlet private weak var precoEbookLabel: UILabel!
    @IBOutlet private weak var precoImpressoLabel: UILabel!
    @IBOutlet private weak var precoComboLabel: UILabel!
    
    @IBOutlet private weak var nomeDoAutorInferiorLabel: UILabel!
    @IBOutlet private weak var conteudoLabel: UILabel!
    @IBOutlet private weak var fotoPerfilImageView: UIImageView!
    @IBOutlet private weak var bioDoAutorLabel: UILabel!
    @IBOutlet private weak var numeroPaginasLabel: UILabel!
    @IBOutlet private weak var isbnLabel: UILabel!
    @IBOutlet private weak var dataPublicacaoLabel: UILabel!
    
    var livro: Livro!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        // Do any additional setup after loading the view.
        atualizaView(com: livro)
    }

    func atualizaView(com livro: Livro) {
        tituloLabel.text = livro.titulo
        subtituloLabel.text = livro.subtitulo
        nomeDoAutorLabel.text = livro.autor.nomeCompleto
        capaImageView.setImageByDowloading(url: livro.imagemDeCapaURI,
                                           placeholderImage: .init(named: "Book"))
    
        conteudoLabel.text = livro.descricao
        nomeDoAutorInferiorLabel.text = livro.autor.nomeCompleto
        fotoPerfilImageView.setImageByDowloading(url: livro.autor.fotoURI)
        bioDoAutorLabel.text = livro.autor.bio
        numeroPaginasLabel.text = String(livro.numeroDePaginas)
        isbnLabel.text = livro.isbn
        dataPublicacaoLabel.text = livro.dataPublicacao
        
        livro.precos.forEach { preco in
            let valor = NumberFormatter.formatToCurrency(decimal: preco.valor)
            switch preco.tipoDeLivro {
            case .ebook:
                precoEbookLabel.text = valor
            case .impresso:
                precoImpressoLabel.text = valor
            case .combo:
                precoComboLabel.text = valor
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "abrirCarrinhoComLivroSegue" else { return }
        
        guard let botaoComprar = sender as? UIButton,
              let controller = segue.destination as? CarrinhoViewController else {
            fatalError("N??o foi poss??vel executar segue \(segue.identifier!)")
        }
        
        guard let tipoSelecionado = TipoDeLivro.allCases
            .filter({ $0.index == botaoComprar.tag }).first else {
            fatalError("N??o foi poss??vel determinar a op????o de tipo de livro ao processar a segue \(segue.identifier!)")
        }
        
        controller.carrinho = Carrinho.constroi(com: livro, doTipo: tipoSelecionado)
    }
    
}

