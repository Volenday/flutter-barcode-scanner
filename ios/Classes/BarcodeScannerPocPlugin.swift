import Flutter
import UIKit
import AVFoundation

public class BarcodeScannerPocPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "barcode_scanner_poc", binaryMessenger: registrar.messenger())
        let instance = BarcodeScannerPocPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            result(FlutterError(code: "UNAVAILABLE", message: "Root view controller not found.", details: nil))
            return
        }
        
        if call.method == "scanBarcode" {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .authorized {
                let scannerViewController = BarcodeScannerViewController(onBarcodeScanned: { barcodeValue in
                    result(barcodeValue)
                })
                rootViewController.present(scannerViewController, animated: true)
            } else if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        if granted {
                            let scannerViewController = BarcodeScannerViewController(onBarcodeScanned: { barcodeValue in
                                result(barcodeValue)
                            })
                            rootViewController.present(scannerViewController, animated: true)
                        } else {
                            result(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied.", details: nil))
                        }
                    }
                }
            } else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied.", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}
