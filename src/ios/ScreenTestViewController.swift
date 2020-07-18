//
//  ScreenTestViewController.swift
//  TestTask
//
//  Created by greetgo on 7/16/20.
//  Copyright © 2020 yelzhan.com. All rights reserved.
//

import UIKit
import PayCardsRecognizer

class ScreenTestViewController: UIViewController {

    
    var firstImage: UIImage?
    var segmentSelectionAtIndex: ((Data, String, String, String) -> ())?
    
    
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
extension ScreenTestViewController: PayCardsRecognizerPlatformDelegate {
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
            }
            
//            recognizer.stopCamera()
//            recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: recognizerContainer, frameColor: .green)
//            recognizer.startCamera()
            recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: recognizerContainer, frameColor: .green)
            recognizer.startCamera()
        }
        // Get data
        else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName == nil {
            let vc = ScreenShowViewController(image: firstImage!,
                                              number: result.recognizedNumber!,
                                              month: "",
                                              year: "",
                                              name: "")
            present(vc, animated: true)
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth == nil && result.recognizedExpireDateYear == nil && result.recognizedHolderName != nil {
            let vc = ScreenShowViewController(image: firstImage!,
                                              number: result.recognizedNumber!,
                                              month: "",
                                              year: "",
                                              name: result.recognizedHolderName!)
            present(vc, animated: true)
        }else if result.recognizedNumber != nil && result.recognizedExpireDateMonth != nil && result.recognizedExpireDateYear != nil && result.recognizedHolderName != nil {
            let vc = ScreenShowViewController(image: firstImage!,
                                              number: result.recognizedNumber!,
                                              month: result.recognizedExpireDateMonth!,
                                              year: result.recognizedExpireDateYear!,
                                              name: result.recognizedHolderName!)
            present(vc, animated: true)
        }
//        else {
//            recognizer.stopCamera()
//            recognizer.startCamera()
//        }
    }
}


//let imageData: Data = (firstImage?.jpegData(compressionQuality: 0.1))!
//segmentSelectionAtIndex?(imageData, result.recognizedNumber!, "", "")


