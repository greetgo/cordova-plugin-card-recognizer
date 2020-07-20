//
//  ScreenTestViewController.swift
//  TestTask
//
//  Created by greetgo on 7/16/20.
//  Copyright © 2020 yelzhan.com. All rights reserved.
//

import UIKit
import PayCardsRecognizer

class CardIOScreenTestViewController: UIViewController {

    
    var firstImage: UIImage?
    var imageData: NSData?
    var segmentSelectionAtIndex: ((NSData, String, String, String) -> ())?
    var backCallBack: (() -> ())?
    
    lazy var alphaBlackTop: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    lazy var alphaBlackBottom: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.text = "Поместите карту в кадр"
        label.textColor = .white
        return label
    }()
    lazy var backButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Ввести данные карты вручную", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(tapBack), for: .touchUpInside)
        return btn
    }()
    
    
    // MARK: - Properties
    private var recognizer: PayCardsRecognizer!
    lazy var recognizerContainer = UIView()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        view.addSubview(recognizerContainer)
        recognizerContainer.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }
        
        view.addSubview(alphaBlackTop)
        alphaBlackTop.snp.makeConstraints { (make) in
            make.top.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        view.addSubview(alphaBlackBottom)
        alphaBlackBottom.snp.makeConstraints { (make) in
            make.width.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
        }
        view.addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalToSuperview()
            make.height.equalTo(50)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.recognizer = PayCardsRecognizer(delegate: self, recognizerMode: .grabCardImage, resultMode: .async, container: self.recognizerContainer, frameColor: .green)
            self.recognizer.startCamera()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recognizer.stopCamera()
    }
    
    
    // MARK: - Actions
    @objc func tapBack() -> Void {
        recognizer.stopCamera()
        backCallBack?()
    }
}


// MARK: - PayCards result delegate
extension CardIOScreenTestViewController: PayCardsRecognizerPlatformDelegate {
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        // Screen shot
        if result.recognizedNumber == nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName == nil {
            let screenImage = UIImage(snapshotOf: self.recognizerContainer)!
            
            if UIDevice.modelName == "iPhone 5" || UIDevice.modelName == "iPhone 5c" || UIDevice.modelName == "iPhone 5s" || UIDevice.modelName == "iPhone SE" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 35, y: 340, width: UIScreen.main.bounds.width * 1.75, height: 340))!
                self.firstImage = imageCut
            }else if UIDevice.modelName == "iPhone 6" || UIDevice.modelName == "iPhone 6s" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 42, y: 414, width: UIScreen.main.bounds.width * 1.75, height: 385))!
                self.firstImage = imageCut
            }else if UIDevice.modelName == "iPhone 11" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 45, y: 590, width: UIScreen.main.bounds.width * 1.75, height: 440))!
                self.firstImage = imageCut
            }else {
                self.firstImage = screenImage
            }
//             self.imageData = (UIImageJPEGRepresentation(self.firstImage!, 1)! as NSData)
               self.imageData = (self.firstImage!.pngData()! as NSData)
            
            recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: recognizerContainer, frameColor: .green)
            recognizer.startCamera()
        }
        // Get data
        else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName == nil {
            segmentSelectionAtIndex?(imageData!, result.recognizedNumber!, "", "")
            recognizer.stopCamera()
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName != nil {
            segmentSelectionAtIndex?(imageData!, result.recognizedNumber!, "", result.recognizedHolderName!)
            recognizer.stopCamera()
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth != nil && result.recognizedExpireDateYear != nil && result.recognizedHolderName == nil {
            segmentSelectionAtIndex?(imageData!, result.recognizedNumber!, "\(result.recognizedExpireDateMonth!)/\(result.recognizedExpireDateYear!)", "")
            recognizer.stopCamera()
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth != nil && result.recognizedExpireDateYear != nil && result.recognizedHolderName != nil {
            segmentSelectionAtIndex?(imageData!, result.recognizedNumber!, "\(result.recognizedExpireDateMonth!)/\(result.recognizedExpireDateYear!)", result.recognizedHolderName!)
            recognizer.stopCamera()
        }
    }
}


//let imageData: Data = (firstImage?.jpegData(compressionQuality: 0.1))!
//segmentSelectionAtIndex?(imageData, result.recognizedNumber!, "", "")


