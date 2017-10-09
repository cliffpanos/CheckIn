//
//  QRCodeScannerViewController.swift
//
//  Created by Sebastian Hunkeler on 18/08/14.
//  Copyright (c) 2014 hsr. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate
{
    var captureSession: AVCaptureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
    var deviceInput:AVCaptureDeviceInput?
    var metadataOutput:AVCaptureMetadataOutput = AVCaptureMetadataOutput()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer!
    public var highlightView:UIView = UIView()
    
    //MARK: Lifecycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        highlightView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        highlightView.layer.borderColor = (UIColor.green as! CGColor)
        highlightView.layer.borderWidth = 3

        let preset = AVCaptureSession.Preset.high
        if(captureSession.canSetSessionPreset(preset)) {
            captureSession.sessionPreset = preset
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    }
    
    override public func viewDidLayoutSubviews() {
        videoPreviewLayer.frame = view.bounds
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(highlightView)
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice!)
        } catch let error as NSError {
             didFailWithError(error: error)
            return
        }
        
        if let captureInput = deviceInput {
            captureSession.addInput(captureInput)
        }
        
        metadataOutput.setMetadataObjectsDelegate(self, queue:DispatchQueue.main)
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        
        videoPreviewLayer.frame = self.view.bounds;
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        view.layer.addSublayer(videoPreviewLayer)
        view.bringSubview(toFront: highlightView)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startQRCodeScanningSession()
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    public func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animate(alongsideTransition: { (context) -> Void in
            let orientation = UIApplication.shared.statusBarOrientation
            self.updateVideoOrientation(orientation: orientation)
        }, completion: nil)
        
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    private func updateVideoOrientation(orientation:UIInterfaceOrientation){

        switch orientation {
        case .portrait :
            videoPreviewLayer.connection?.videoOrientation = .portrait
            break
        case .portraitUpsideDown :
            videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
            break
        case .landscapeLeft :
            videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
            break
        case .landscapeRight :
            videoPreviewLayer.connection?.videoOrientation = .landscapeRight
            break
        default:
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }
    
    //MARK: QR Code Processing
    
    /**
    * Processes the string content fo the QR code. This method should be overridden
    * in subclasses.
    * @param qrCodeContent The content of the QR code as string.
    * @return A booloean indicating whether the QR code could be processed.
    **/
     public func processQRCodeContent(qrCodeContent:String) -> Bool {
        print(qrCodeContent)
        return false
    }
    
    /**
    * Catch error when the controller is loading. This method can be overriden
    * in subclasses to detect error. Do not dismiss controller immediately.
    * @param error The error object
    **/
    public func didFailWithError(error: NSError) {
        print("Error: \(error.description)")
    }
    
    /**
     * Starts the scanning session using the built in camera.
     **/
    public func startQRCodeScanningSession(){
        updateVideoOrientation(orientation: UIApplication.shared.statusBarOrientation)
        highlightView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        captureSession.startRunning()
    }
    
    /**
     Stops the scanning session
     */
    public func stopQRCodeScanningSession(){
        captureSession.stopRunning()
        highlightView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
    
    //MARK: AVCaptureMetadataOutputObjectsDelegate
    
    @nonobjc public func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        var highlightViewRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        var barCodeObject: AVMetadataMachineReadableCodeObject
        var detectionString:String?
        self.highlightView.frame = highlightViewRect
        
        for metadata in metadataObjects {
            if let metadataObject = metadata as? AVMetadataObject {
                
                if (metadataObject.type == AVMetadataObject.ObjectType.qr) {
                    barCodeObject = videoPreviewLayer.transformedMetadataObject(for: metadataObject) as! AVMetadataMachineReadableCodeObject
                    highlightViewRect = barCodeObject.bounds
                    self.highlightView.frame = highlightViewRect
                    
                    if let machineReadableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                        detectionString = machineReadableObject.stringValue
                    }
                }
                
                if let qrCodeContent = detectionString {
                    captureSession.stopRunning()
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.highlightView.alpha = 0
                    }, completion: { (complete) -> Void in
                        if !self.processQRCodeContent(qrCodeContent: qrCodeContent) {
                            self.highlightView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
                            self.highlightView.alpha = 1
                            self.captureSession.startRunning()
                        }
                    })
                    return
                }
            }
        }
    }
    
}
