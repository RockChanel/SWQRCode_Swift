//
//  SWQRCodeViewController.swift
//  SWQRCode_Swift
//
//  Created by zhuku on 2018/4/11.
//  Copyright © 2018年 selwyn. All rights reserved.
//

import UIKit
import AVFoundation

class SWQRCodeViewController: UIViewController {
    
    var config = SWQRCodeCompat()
    private let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = SWQRCodeHelper.sw_navigationItemTitle(type: self.config.scannerType)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: .UIApplicationWillResignActive, object: nil)
        
        _setupUI();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _resumeScanning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 关闭并隐藏手电筒
        scannerView.sw_setFlashlight(on: false)
        scannerView.sw_hideFlashlight(animated: true)
    }
    
    private func _setupUI() {
        view.backgroundColor = .black
        
        let albumItem = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(showAlbum))
        albumItem.tintColor = .black
        navigationItem.rightBarButtonItem = albumItem;
        
        view.addSubview(scannerView)
        
        // 校验相机权限
        SWQRCodeHelper.sw_checkCamera { (granted) in
            if granted {
                DispatchQueue.main.async {
                    self._setupScanner()
                }
            }
        }
    }
    
    /** 创建扫描器 */
    private func _setupScanner() {
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        if let deviceInput = try? AVCaptureDeviceInput(device: device) {
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            
            if config.scannerArea == .def {
                metadataOutput.rectOfInterest = CGRect(x: scannerView.scanner_y/view.frame.size.height, y: scannerView.scanner_x/view.frame.size.width, width: scannerView.scanner_width/view.frame.size.height, height: scannerView.scanner_width/view.frame.size.width)
            }
            
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: .main)
            
            session.canSetSessionPreset(.high)
            if session.canAddInput(deviceInput) { session.addInput(deviceInput) }
            if session.canAddOutput(metadataOutput) { session.addOutput(metadataOutput) }
            if session.canAddOutput(videoDataOutput) { session.addOutput(videoDataOutput) }
            
            metadataOutput.metadataObjectTypes = SWQRCodeHelper.sw_metadataObjectTypes(type: config.scannerType)
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.insertSublayer(videoPreviewLayer, at: 0)
            
            session.startRunning()
        }
    }
    
    @objc func showAlbum() {
        SWQRCodeHelper.sw_checkAlbum { (granted) in
            if granted {
                self.imagePicker()
            }
        }
    }

// MARK: - 跳转相册
    private func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    /// 从后台进入前台
    @objc func appDidBecomeActive() {
        _resumeScanning()
    }
    
    /// 从前台进入后台
    @objc func appWillResignActive() {
        _pauseScanning()
    }
    
    lazy var scannerView:SWScannerView = {
        let tempScannerView = SWScannerView(frame: view.bounds, config: config)
        return tempScannerView
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - 扫一扫Api
extension SWQRCodeViewController {
    
    /// 处理扫一扫结果
    ///
    /// - Parameter value: 扫描结果
    func sw_handle(value: String) {
        print("sw_handle === \(value)")
    }
    
    /// 相册选取图片无法读取数据
    func sw_didReadFromAlbumFailed() {
        print("sw_didReadFromAlbumFailed")
    }
}

// MARK: - 扫描结果处理
extension SWQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        if metadataObjects.count > 0 {
            _pauseScanning()

            if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if let stringValue = metadataObject.stringValue {
                    sw_handle(value: stringValue)
                }
            }
        }
    }
}

// MARK: - 监听光线亮度
extension SWQRCodeViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let metadataDict = CMCopyDictionaryOfAttachments(nil, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        
        if let metadata = metadataDict as? [AnyHashable: Any] {
            if let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [AnyHashable: Any] {
                if let brightness = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? NSNumber {
                    // 亮度值
                    let brightnessValue = brightness.floatValue
                    if !scannerView.sw_setFlashlightOn() {
                        if brightnessValue < -4.0 {
                            scannerView.sw_showFlashlight(animated: true)
                        }
                        else {
                            scannerView.sw_hideFlashlight(animated: true)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 识别选择图片
extension SWQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if !self.handlePickInfo(info) {
                self.sw_didReadFromAlbumFailed()
            }
        }
    }
    
    /// 识别二维码并返回识别结果
    private func handlePickInfo(_ info: [String : Any]) -> Bool {
        if let pickImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let ciImage = CIImage(cgImage: pickImage.cgImage!)
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
            
            if let features = detector?.features(in: ciImage),
                let firstFeature = features.first as? CIQRCodeFeature{

                if let stringValue = firstFeature.messageString {
                    sw_handle(value: stringValue)
                    return true
                }
                return false
            }
        }
        return false
    }
}

// MARK: - 恢复/暂停扫一扫功能
extension SWQRCodeViewController {
    
    /// 恢复扫一扫功能
    private func _resumeScanning() {
        session.startRunning()
        scannerView.sw_addScannerLineAnimation()
    }
    
    /// 暂停扫一扫功能
    private func _pauseScanning() {
        session.stopRunning()
        scannerView.sw_pauseScannerLineAnimation()
    }
}

