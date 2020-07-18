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
    var segmentSelectionAtIndex: ((UIImage, String, String, String) -> ())?
    
    
    // MARK: - Properties
    private var recognizer: PayCardsRecognizer!
    lazy var recognizerContainer = UIView()
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.addSubview(recognizerContainer)
        recognizerContainer.snp.makeConstraints { (make) in
            make.top.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.7)
        }
        recognizer = PayCardsRecognizer(delegate: self, recognizerMode: .grabCardImage, resultMode: .async, container: recognizerContainer, frameColor: .green)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recognizer.startCamera()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        recognizer.stopCamera()
    }
}


// MARK: - PayCards result delegate
extension CardIOScreenTestViewController: PayCardsRecognizerPlatformDelegate {
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        // Screen shot
        if result.recognizedNumber == nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName == nil {
            let screenImage = UIImage(snapshotOf: self.recognizerContainer)!
            
            if UIDevice.modelName == "iPhone 5" || UIDevice.modelName == "iPhone 5c" || UIDevice.modelName == "iPhone 5s" || UIDevice.modelName == "iPhone SE" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 10, y: 225, width: 650, height: 345))!
                self.firstImage = imageCut
            }else if UIDevice.modelName == "iPhone 6" || UIDevice.modelName == "iPhone 6s" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 20, y: 260, width: 710, height: 400))!
                self.firstImage = imageCut
            }else if UIDevice.modelName == "iPhone 11" {
                let imageCut: UIImage = screenImage.cropImage(toRect: CGRect(x: 45, y: 400, width: 735, height: 450))!
                self.firstImage = imageCut
            }else {
                self.firstImage = screenImage
            }
            recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: recognizerContainer, frameColor: .green)
            recognizer.startCamera()
        }
        // Get data
        else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName == nil {
            segmentSelectionAtIndex?(firstImage!, result.recognizedNumber!, "", "")
            recognizer.stopCamera()
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName != nil {
            segmentSelectionAtIndex?(firstImage!, result.recognizedNumber!, "", result.recognizedHolderName!)
            recognizer.stopCamera()
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth != nil && result.recognizedExpireDateYear != nil && result.recognizedHolderName != nil {
            segmentSelectionAtIndex?(firstImage!, result.recognizedNumber!, "\(result.recognizedExpireDateMonth!)/\(result.recognizedExpireDateYear!)", result.recognizedHolderName!)
            recognizer.stopCamera()
        }
    }
}


//let imageData: Data = (firstImage?.jpegData(compressionQuality: 0.1))!
//segmentSelectionAtIndex?(imageData, result.recognizedNumber!, "", "")


