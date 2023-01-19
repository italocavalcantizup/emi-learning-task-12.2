//
//  NovoLivroViewController.swift
//  LearningTask-12.2
//
//  Created by Italo cavalcanti on 12/01/23.
//

import UIKit

protocol NovoLivroViewControllerDelegate: AnyObject {
    func novoLivroViewController(_ viewController: NovoLivroViewController, adicionou livro: Livro)
}

class NovoLivroViewController: UIViewController {
    
    typealias MensagemDeValidacao = String
    
    weak var delegate: NovoLivroViewControllerDelegate?
    
    var livrosAPI: LivrosAPI?
    
    private var autor: Autor? {
        didSet {
            guard let autor = autor else { return }
            autorTextField.text = autor.nomeCompleto
            
        }
    }
    
    var placeholder = "Descrição do Livro"
    
    @IBOutlet weak var fotoCapaImageView: UIImageView!
    @IBOutlet weak var fotoCapaTextField: UITextField!
    @IBOutlet weak var tituloTextField: UITextField!
    @IBOutlet weak var subtituloTextField: UITextField!
    @IBOutlet weak var autorTextField: UITextField!
    @IBOutlet weak var descricaoTextView: UITextView!
    @IBOutlet weak var precoEbookTextField: UITextField!
    @IBOutlet weak var precoImpressoTextField: UITextField!
    @IBOutlet weak var precoComboTextField: UITextField!
    @IBOutlet weak var numeroPaginasTextField: UITextField!
    @IBOutlet weak var isbnTextField: UITextField!
    @IBOutlet weak var dataPublicacaoTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureTextView()
        autorTextField.addTarget(self, action: #selector(selecaoAutorClicado), for: .editingDidBegin)
    }
    
    @objc func selecaoAutorClicado() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let seletorAutorViewController = (storyboard.instantiateViewController(withIdentifier: "SeletorDeAutorViewController") as! SeletorDeAutorViewController)
        seletorAutorViewController.autoresAPI = AutoresAPI(httpRequest: HTTPRequest())
        seletorAutorViewController.delegate = self
        self.present(seletorAutorViewController, animated: true, completion: nil)
    }
    
    private func configureTextView() {
        descricaoTextView.delegate = self
        textViewDidBeginEditing(descricaoTextView)
        descricaoTextView.text = placeholder
        
        descricaoTextView.layer.cornerRadius = 6
        descricaoTextView.layer.borderWidth = 1
        descricaoTextView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    private func nomeDeAutorValido(_ nome: String) -> Bool {
        let pattern = #"^[a-zA-Z-]+ ?.* [a-zA-Z-]+$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: nome)
    }
    
    @IBAction func fotoCapaTextFieldEditingDidEnd(_ sender: UITextField) {
        guard let urlString = sender.text,
              let url = URL(string: urlString) else { return }
        
        fotoCapaImageView.setImageByDowloading(url: url,
                                               placeholderImage: .init(named: "Avatar"),
                                               animated: true)
    }
    
    @IBAction func adicionarLivroPressionado(_ sender: UIButton) {
        switch formularioEhValido() {
        case (false, let mensagem):
            UIAlertController.showError(mensagem!, in: self)
        default:
            cadastraLivro()
        }
    }
    
    private func formularioEhValido() -> (Bool, MensagemDeValidacao?) {
        guard let urlString = fotoCapaTextField.text,
              let _ = URL(string: urlString) else {
            return (false, "Informe a URL da foto do autor.")
        }
        
        if let titulo = tituloTextField.text, titulo.isEmpty {
            return (false, "Título não pode estar em branco.")
        }
        
        if let subtitulo = subtituloTextField.text, subtitulo.isEmpty {
            return (false, "Subtítulo não pode estar em branco.")
        }
        
        guard let nomeAutor = autorTextField.text, !nomeAutor.isEmpty else {
            return (false, "Nome do autor não pode estar em branco.")
        }
        
        guard nomeDeAutorValido(nomeAutor) else {
            return (false, "Informe o nome completo do autor.")
        }
        
        if let descricao = descricaoTextView.text, descricao.isEmpty {
            return (false, "Preencha uma descrição.")
        }
        
        if let precoEbook = precoEbookTextField.text, precoEbook.isEmpty {
            return (false, "Defina um preço para a versão digital.")
        }
        
        if let precoImpresso = precoImpressoTextField.text, precoImpresso.isEmpty {
            return (false, "Defina um preço para a versão impressa.")
        }
        
        if let precoCombo = precoComboTextField.text, precoCombo.isEmpty {
            return (false, "Defina um preço para o combo.")
        }
        
        
        if let numeroPaginas = numeroPaginasTextField.text, numeroPaginas.isEmpty {
            return (false, "Preencha com a quantidade de páginas do livro.")
        }
        
        if let isbn = isbnTextField.text, isbn.isEmpty {
            return (false, "Preencha o ISBN.")
        }
        
        
        if let dataPublicacao = dataPublicacaoTextField.text, dataPublicacao.isEmpty {
            return (false, "Preencha a data de publicação.")
        }
        
        return (true, nil)
    }
    
    private func cadastraLivro() {
        let precoEbook = Decimal(string: precoEbookTextField.text!) ?? 0.0
        let precoImpresso = Decimal(string: precoImpressoTextField.text!) ?? 0.0
        let precoCombo = Decimal(string: precoComboTextField.text!) ?? 0.0
        
        let livro = Livro(titulo: tituloTextField.text!,
                          subtitulo: subtituloTextField.text!,
                          imagemDeCapaURI: URL(string: fotoCapaTextField.text!)!,
                          descricao: descricaoTextView.text!,
                          autor: self.autor!,
                          precos: [
                            Preco(valor: precoEbook, tipoDeLivro: .ebook),
                            Preco(valor: precoImpresso, tipoDeLivro: .impresso),
                            Preco(valor: precoCombo, tipoDeLivro: .combo),
                          ],
                          isbn: isbnTextField.text!,
                          dataPublicacao: dataPublicacaoTextField.text!,
                          numeroDePaginas: Int(numeroPaginasTextField.text!) ?? 0)
        
        livrosAPI?.registerBook(livro){ [weak self] result in
            switch result{
            case .success(let livro):
                self?.dismiss(animated: true, completion: {
                    self?.delegate?.novoLivroViewController(self!, adicionou: livro)
                })
            case .failure(let erro):
                debugPrint(erro)
                let mensagem = "Não foi possível adicionar o livro. \(erro.localizedDescription)"
                UIAlertController.showError(mensagem, in: self!)
            }
        }
    }
    
}

extension NovoLivroViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            print("É igual ao Placeholder")
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            print("TextView está vazio")
            textView.text = placeholder
        }
    }
}

extension NovoLivroViewController: SeletorDeAutorViewControllerDelegate {
    func seletorDeAutorViewController(_ controller: SeletorDeAutorViewController, selecionouAutor autor: Autor) {
        self.autor = autor
    }
}
