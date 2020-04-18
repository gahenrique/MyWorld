//
//  ContractViewController.swift
//  MyWorld
//
//  Created by gabriel on 18/04/20.
//  Copyright © 2020 gabriel. All rights reserved.
//

import UIKit
import PDFKit

class ContractViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: nil)
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fechar", style: .done, target: self, action: #selector(close))

        let pdfView = PDFView(frame: self.view.bounds)
        self.view.addSubview(pdfView)
        
        pdfView.displayDirection = .vertical
        pdfView.autoScales = true
        
        let doc = createPDF()
        pdfView.document = doc
    }
    
    private func createPDF() -> PDFDocument? {
        guard let document = Bundle.main.loadNibNamed("DocumentViewPDF", owner: nil, options: nil)?.first as? UIViewController else {return nil}
        
        let format = UIGraphicsPDFRendererFormat()
        let metaData = [kCGPDFContextTitle: "Contrato", kCGPDFContextAuthor: "MyWorld"]
        format.documentInfo = metaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            document.view.layer.render(in: context.cgContext)
        }
        
        guard let doc = PDFDocument(data: data) else { return nil }
        return doc
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

}
