//
//  ContractViewController.swift
//  MyWorld
//
//  Created by gabriel on 18/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit
import PDFKit

protocol ContractViewControllerDelegate {
    func setup(_ completion: (_ regent:Territory) -> Void)
}

class ContractViewController: UIViewController {
    
    var pdfView: PDFView?
    var delegate: ContractViewControllerDelegate?
    var territory: Territory?

    func setupContract() -> String {
        guard let territory = territory,
            let regent = territory.regent else { return "" }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: date)
        
        let contract = """
        Regente: \(regent).

        Pelo presente documento, fica justo e contratado o que segue:

        CLÁUSULA 1ª - O Líder do planeta, declara ser o proprietário legítimo do território de código \(territory.code), localizado em (\(Int(territory.site.y)), \(Int(territory.site.x))) e área total de \(String(format: "%.2f", territory.area))kmˆ2.

        CLÁUSULA 2ª - É de livre e espontânea vontade do líder supremo, não existindo vício de vontade de qualquer pessoa, fazer a atribuição, ao \(regent) transferindo desde já ao novo regente os direitos de administração do território.

        CLÁUSULA 3ª - O novo regente afirma aceitar este termo de confiança como rezado neste instrumento, para que lhe fique responsável a regência do território atribuído.
        
        CLÁUSULA 4ª - Este documento pode ser revogado quando o líder do planeta quiser, portanto não possui serventia alguma.

        Para firmeza e como prova de assim justos e contratados, o líder enviará via ZAP este documento.

        \(dateString)

        Líder do planeta

        \(regent)
        """
        return contract
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
//        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(close))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        pdfView = PDFView(frame: self.view.bounds)
        
        guard let pdfView = pdfView else { return }
        self.view.addSubview(pdfView)
        
        pdfView.displayDirection = .vertical
        pdfView.autoScales = true
        let doc = createPDF()
        pdfView.document = doc
    }
    
    private func createPDF() -> PDFDocument? {
        delegate?.setup({ (territory) in
            self.territory = territory
        })
        
        let contractView = UIView(frame: CGRect(x: 0, y: 0, width: 595, height: 842))
        let text = UILabel()
        contractView.backgroundColor = .white
        contractView.addSubview(text)
        text.textAlignment = .left
        text.text = setupContract()
        text.textColor = .black
        text.adjustsFontForContentSizeCategory = true
        text.numberOfLines = 0
        text.lineBreakMode = .byWordWrapping
        
        contractView.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        contractView.heightAnchor.constraint(equalToConstant: 842).isActive = true
        contractView.widthAnchor.constraint(equalToConstant: 595).isActive = true
        text.widthAnchor.constraint(equalToConstant: 495).isActive = true
        text.topAnchor.constraint(equalTo: contractView.topAnchor, constant: 50).isActive = true
        text.leadingAnchor.constraint(equalTo: contractView.leadingAnchor, constant: 50).isActive = true
                
        contractView.layoutIfNeeded()
                                
        let format = UIGraphicsPDFRendererFormat()
        let metaData = [kCGPDFContextTitle: "Contrato de regência", kCGPDFContextAuthor: "MyWorld"]
        format.documentInfo = metaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: contractView.bounds, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            contractView.layer.render(in: context.cgContext)
        }
        
        guard let doc = PDFDocument(data: data) else { return nil }
        return doc
    }
    
    @objc private func share() {
        guard let pdf = pdfView?.document?.dataRepresentation() else {return }
        let activityViewController = UIActivityViewController(activityItems: [pdf], applicationActivities: nil)

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

}
