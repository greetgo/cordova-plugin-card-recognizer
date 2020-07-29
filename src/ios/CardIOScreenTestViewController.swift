//
//  ScreenTestViewController.swift
//  TestTask
//
//  Created by greetgo on 7/16/20.
//  Copyright © 2020 yelzhan.com. All rights reserved.
//

import UIKit
import AVFoundation
import PayCardsRecognizer

class CardIOScreenTestViewController: UIViewController {
    
    var segmentSelectionAtIndex: ((NSData, String, String, String) -> ())?
    var backCallBack: (() -> ())?
    var shot: Bool = true
    
    var firstImage: UIImage?
    var number: String?
    var month: String?
    var year: String?
    var name: String?
    
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
        btn.setTitle("Вернуться назад", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
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
        
        setupViews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: self.recognizerContainer, frameColor: .green)
            self.recognizer.startCamera()
        }
    }
    
    
    // MARK: - Functions
    func setupViews() -> Void {
        view.backgroundColor = hexStringToUIColor(hex: "#1d3664")
        
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
            make.bottom.equalToSuperview().offset(0)
            make.width.equalToSuperview()
            make.height.equalTo(70)
        }
    }
    func hexStringToUIColor (hex: String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    
    // MARK: - Actions
    @objc func tapBack() -> Void {
        recognizer.stopCamera()
        backCallBack?()
    }
    func imageCut() -> Void {
        recognizer.stopCamera()
        let imageData = (self.firstImage!.jpegData(compressionQuality: 1.0)! as NSData)
        segmentSelectionAtIndex?(imageData, number!, "\(month!)/\(year!)", name!)
    }
}


// MARK: - PayCards result delegate
extension CardIOScreenTestViewController: PayCardsRecognizerPlatformDelegate {
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        result.recognizedNumber == nil ? (number = "") : (number = result.recognizedNumber)
        result.recognizedExpireDateMonth == nil ? (month = "") : (month = result.recognizedExpireDateMonth)
        result.recognizedExpireDateYear == nil ? (year = "") : (year = result.recognizedExpireDateYear)
        result.recognizedHolderName == nil ? (name = "") : (name = result.recognizedHolderName)

        if result.image != nil {
            self.firstImage = result.image;
            imageCut()
        }
    }
}
