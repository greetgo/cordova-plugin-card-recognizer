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
import MBProgressHUD

class CardIOScreenTestViewController: UIViewController {
    
    var segmentSelectionAtIndex: ((NSData, String, String, String) -> ())?
    var backCallBack: (() -> ())?
    var shot: Bool = true

    var colorBackground: String? = "#1d3664"
    var firstImage: UIImage?
    var number: String?
    var month: String?
    var year: String?
    var name: String?
    
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

    //canvas
    lazy var sampleMask: UIView = {
        let sampleMask = UIView()
        sampleMask.frame = view.frame
        sampleMask.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return sampleMask
    }()
    lazy var circleLayer: CAShapeLayer = {
        let circleLayer = CAShapeLayer()
        circleLayer.borderColor = UIColor.white.withAlphaComponent(1).cgColor
        circleLayer.borderWidth = 1
        circleLayer.frame = CGRect(x:0, y:0, width:sampleMask.frame.size.width, height:sampleMask.frame.size.height)
        return circleLayer
    }()
    lazy var maskLayer: CALayer = {
        let maskLayer = CALayer()
        maskLayer.frame = sampleMask.bounds
        maskLayer.addSublayer(circleLayer)
        return maskLayer
    }()


    // MARK: - Properties
    private var recognizer: PayCardsRecognizer!
    lazy var recognizerContainer = UIView()


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        let huder = MBProgressHUD.showAdded(to: self.view, animated: true)
        huder.bezelView.color = hexStringToUIColor(hex: self.colorBackground)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: self.recognizerContainer, frameColor: .green)
            self.recognizer.startCamera()

            huder.hide(animated: true)
        }
    }


    // MARK: - Functions
    func setupViews() -> Void {
        view.backgroundColor = hexStringToUIColor(hex: self.colorBackground)

        view.addSubview(recognizerContainer)
        recognizerContainer.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }

        // Canvas
        view.addSubview(sampleMask)
        let finalPath =
            UIBezierPath(roundedRect: CGRect(x:0, y:0, width:sampleMask.frame.size.width, height:sampleMask.frame.size.height), cornerRadius: 0)
        let width = UIScreen.main.bounds.width
        let height0 = ceil(UIScreen.main.bounds.width * 1 * 0.65)
        let y0 = Int((UIScreen.main.bounds.height * 1) - height0) / 2

        let circlePath = UIBezierPath(roundedRect: CGRect(x: Int(width * 0.025),
                                                          y: y0+10,
                                                          width: Int(width * 0.95),
                                                          height: Int(height0-20)),
                                      cornerRadius: 15)
        finalPath.append(circlePath.reversing())
        circleLayer.path = finalPath.cgPath
        sampleMask.layer.mask = maskLayer

        //just view
        sampleMask.addSubview(topLabel)
        sampleMask.addSubview(backButton)
        topLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150)
            make.centerX.equalToSuperview()
        }
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
        let imageData = (self.firstImage!.jpegData(compressionQuality: 0.5)! as NSData)
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
