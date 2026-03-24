import UIKit
import AVFoundation
import Vision

class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Propiedades
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var output: AVCaptureVideoDataOutput?
    var captureDevice: AVCaptureDevice?

    // Variable para almacenar el resultado del escaneo
    var onBarcodeScanned: ((String?) -> Void)?

    // ✅ Añadido el inicializador requerido para la clase
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // ✅ Inicializador personalizado para pasar el callback
    init(onBarcodeScanned: @escaping (String?) -> Void) {
        super.init(nibName: nil, bundle: nil)
        self.onBarcodeScanned = onBarcodeScanned
    }

    // MARK: - Ciclo de vida de la vista
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        // Configurar la cámara
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        self.captureDevice = videoCaptureDevice
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        // Configurar la salida de datos de video
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_output_queue"))
            self.output = videoOutput
        } else {
            return
        }

        // Configurar la capa de vista previa
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // --- AUTOFOCUS EN EL CENTRO ---
        setAutofocusToCenter()

        // Iniciar la sesión
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Manejo de la captura de video
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Lógica de detección de códigos de barras
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else { return }
            
            // Si se detecta un código, cerrar la vista y pasar el resultado
            if let firstBarcode = results.first {
                self.onBarcodeScanned?(firstBarcode.payloadStringValue)
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([barcodeRequest])
        } catch {
            print("Error al realizar la solicitud de detección de códigos de barras: \(error)")
        }
    }

    // --- AUTOFOCUS EN EL CENTRO ---
    func setAutofocusToCenter() {
        guard let device = captureDevice, device.isFocusPointOfInterestSupported, device.isFocusModeSupported(.continuousAutoFocus) else { return }
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        } catch {
            print("No se pudo configurar el autofocus: \(error)")
        }
    }
}