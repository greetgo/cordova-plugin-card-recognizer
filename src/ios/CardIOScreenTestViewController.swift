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
        recognizerPhotoStart()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.recognizerStart()
        }
    }
    
    
    
    // MARK: - Functions
    func setupViews() -> Void {
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
        
        cameraView.isHidden = true
        view.addSubview(cameraView)
        cameraView.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.9)
        }
    }
    func recognizerStart() -> Void {
        self.recognizer = PayCardsRecognizer(delegate: self, resultMode: .async, container: self.recognizerContainer, frameColor: .green)
        self.recognizer.startCamera()
    }
    
    
    // MARK: - CustomCamera Functions
    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var frontDevice: AVCaptureDevice?
    var frontInput: AVCaptureInput?
    
    lazy var cameraView: UIView = {
        let view = UIView()
        return view
    }()
    
    func recognizerPhotoStart() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        cameraOutput = AVCapturePhotoOutput()

        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.frame = cameraView.bounds
                    cameraView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else { print("issue here : captureSesssion.canAddInput") }
        } else { print("some problem here") }
    }
    func takePhoto() -> Void {
        captureSession.startRunning()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let settings = AVCapturePhotoSettings()
            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            let previewFormat = [ kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                                  kCVPixelBufferWidthKey as String: 160,
                                  kCVPixelBufferHeightKey as String: 160 ]
            settings.previewPhotoFormat = previewFormat
            self.cameraOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    
    // MARK: - Actions
    @objc func tapBack() -> Void {
        captureSession.stopRunning()
        recognizer.stopCamera()
        backCallBack?()
    }
    func imageCute() -> Void {
        if UIDevice.modelName == "iPhone 5" || UIDevice.modelName == "iPhone 5c" || UIDevice.modelName == "iPhone 5s" || UIDevice.modelName == "iPhone SE" {
            let imageCut: UIImage = firstImage!.croppedInRect(rect: CGRect(x: 35, y: 340, width: UIScreen.main.bounds.width * 1.75, height: 340))
            self.firstImage = imageCut
        }else if UIDevice.modelName == "iPhone 6" || UIDevice.modelName == "iPhone 6s" || UIDevice.modelName == "iPhone 7" || UIDevice.modelName == "iPhone 8" {
            let imageCut: UIImage = firstImage!.croppedInRect(rect: CGRect(x: 42, y: 414, width: UIScreen.main.bounds.width * 1.75, height: 385))
            self.firstImage = imageCut
        }else if UIDevice.modelName == "iPhone 11" {
            let imageCut = firstImage!.croppedInRect(rect: CGRect(x: 20, y: 560, width: UIScreen.main.bounds.width * 1.5, height: 250))
            self.firstImage = imageCut
        }else {}
        
        let imageData = (self.firstImage!.jpegData(compressionQuality: 1.0)! as NSData)
        segmentSelectionAtIndex?(imageData, number!, "\(month!)/\(year!)", name!)
    }
}


// MARK: - AVCapturePhotoCaptureDelegate
extension CardIOScreenTestViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error { print("error occured : \(error.localizedDescription)") }
        if let dataImage = photo.fileDataRepresentation() {
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            self.firstImage = image
            imageCute()
        }else {print("some error here")}
    }
}


// MARK: - PayCards result delegate
extension CardIOScreenTestViewController: PayCardsRecognizerPlatformDelegate {
    func payCardsRecognizer(_ payCardsRecognizer: PayCardsRecognizer, didRecognize result: PayCardsRecognizerResult) {
        result.recognizedNumber == nil ? (number = "") : (number = result.recognizedNumber)
        result.recognizedExpireDateMonth == nil ? (month = "") : (month = result.recognizedExpireDateMonth)
        result.recognizedExpireDateYear == nil ? (year = "") : (year = result.recognizedExpireDateYear)
        result.recognizedHolderName == nil ? (name = "") : (name = result.recognizedHolderName)
        
        recognizer.stopCamera()
        takePhoto()
    }
}
