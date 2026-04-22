import UIKit
import AVFoundation
import Vision

class BarcodeScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Properties
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var output: AVCaptureVideoDataOutput?
    var captureDevice: AVCaptureDevice?

    /// Payload to Flutter: `outcome` = success | overlay_back | cancelled
    var onScanResult: (([String: Any]) -> Void)?

    /// Optional label text at the top-left (below the safe area).
    var overlayLabel: String?

    /// Style map from Flutter (ARGB, logical dp, etc.).
    var overlayLabelStyle: [String: Any]?

    /// If true, a back-arrow control closes the scanner (and the label is not tappable).
    var overlayLabelCloseOnTap: Bool = false

    private var overlayLabelView: UILabel?
    private var overlayContainerView: UIView?

    // Required initializer (unused)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Custom initializer with callback
    init(
        onScanResult: @escaping ([String: Any]) -> Void,
        overlayLabel: String? = nil,
        overlayLabelStyle: [String: Any]? = nil,
        overlayLabelCloseOnTap: Bool = false
    ) {
        super.init(nibName: nil, bundle: nil)
        self.onScanResult = onScanResult
        self.overlayLabel = overlayLabel
        self.overlayLabelStyle = overlayLabelStyle
        self.overlayLabelCloseOnTap = overlayLabelCloseOnTap
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()

        // Configure camera
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

        // Configure video data output
        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_output_queue"))
            self.output = videoOutput
        } else {
            return
        }

        // Configure preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        let labelText = overlayLabel?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let hasLabel = !labelText.isEmpty
        let showBack = overlayLabelCloseOnTap

        if hasLabel || showBack {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 6
            row.translatesAutoresizingMaskIntoConstraints = false

            if showBack {
                let backBtn = UIButton(type: .system)
                if #available(iOS 13.0, *) {
                    backBtn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
                } else {
                    backBtn.setTitle("\u{2039}", for: .normal)
                    backBtn.titleLabel?.font = .systemFont(ofSize: 28, weight: .semibold)
                }
                backBtn.tintColor = .white
                backBtn.addTarget(self, action: #selector(overlayBackTapped), for: .touchUpInside)
                backBtn.accessibilityLabel = NSLocalizedString("Back", comment: "Scanner overlay back")
                backBtn.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    backBtn.widthAnchor.constraint(equalToConstant: 44),
                    backBtn.heightAnchor.constraint(equalToConstant: 44),
                ])
                row.addArrangedSubview(backBtn)
            }

            if hasLabel {
                let container = UIView()
                container.translatesAutoresizingMaskIntoConstraints = false
                container.backgroundColor = .clear
                container.layer.cornerRadius = 0
                container.clipsToBounds = false

                let label = UILabel()
                label.text = labelText
                label.textColor = .white
                label.font = .systemFont(ofSize: 14, weight: .medium)
                label.numberOfLines = 3
                label.lineBreakMode = .byTruncatingTail
                label.textAlignment = .left
                label.translatesAutoresizingMaskIntoConstraints = false

                var padH: CGFloat = 10
                var padV: CGFloat = 6
                applyOverlayStyleMap(overlayLabelStyle, container: container, label: label, paddingH: &padH, paddingV: &padV)

                container.addSubview(label)
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: container.topAnchor, constant: padV),
                    label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: padH),
                    label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -padH),
                    label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -padV),
                ])
                row.addArrangedSubview(container)
                overlayLabelView = label
                overlayContainerView = container
            }

            view.addSubview(row)
            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
                row.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                row.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            ])
        }

        // Center autofocus
        setAutofocusToCenter()

        // Start session
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
    
    // MARK: - Video capture
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Barcode detection
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let barcodeRequest = VNDetectBarcodesRequest { [weak self] request, error in
            guard let self = self else { return }
            guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else { return }
            
            // On detection, close and return result
            if let firstBarcode = results.first {
                let code = firstBarcode.payloadStringValue ?? ""
                self.onScanResult?(["outcome": "success", "code": code])
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([barcodeRequest])
        } catch {
            print("Barcode detection request failed: \(error)")
        }
    }

    @objc private func overlayBackTapped() {
        onScanResult?(["outcome": "overlay_back"])
        dismiss(animated: true)
    }

    private func applyOverlayStyleMap(
        _ style: [String: Any]?,
        container: UIView,
        label: UILabel,
        paddingH: inout CGFloat,
        paddingV: inout CGFloat
    ) {
        guard let style = style, !style.isEmpty else { return }

        if let n = style["backgroundColor"] as? NSNumber {
            container.backgroundColor = uiColorFromArgb(Int(truncating: n))
            container.clipsToBounds = true
        }
        if let n = style["borderRadius"] as? NSNumber {
            container.layer.cornerRadius = CGFloat(truncating: n)
        }
        if let n = style["textColor"] as? NSNumber {
            label.textColor = uiColorFromArgb(Int(truncating: n))
        }
        if style["fontSize"] != nil || style["fontWeight"] != nil {
            var fontSize: CGFloat = 14
            if let n = style["fontSize"] as? NSNumber {
                fontSize = CGFloat(truncating: n)
            }
            var weight: UIFont.Weight = .medium
            if let n = style["fontWeight"] as? NSNumber {
                weight = fontWeightFromInt(Int(truncating: n))
            }
            label.font = .systemFont(ofSize: fontSize, weight: weight)
        }
        if let n = style["paddingHorizontal"] as? NSNumber {
            paddingH = CGFloat(truncating: n)
        }
        if let n = style["paddingVertical"] as? NSNumber {
            paddingV = CGFloat(truncating: n)
        }
    }

    private func uiColorFromArgb(_ argb: Int) -> UIColor {
        let a = CGFloat((argb >> 24) & 0xff) / 255.0
        let r = CGFloat((argb >> 16) & 0xff) / 255.0
        let g = CGFloat((argb >> 8) & 0xff) / 255.0
        let b = CGFloat(argb & 0xff) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    private func fontWeightFromInt(_ v: Int) -> UIFont.Weight {
        switch v {
        case ..<200: return .ultraLight
        case ..<300: return .thin
        case ..<400: return .light
        case ..<500: return .regular
        case ..<600: return .medium
        case ..<700: return .semibold
        case ..<800: return .bold
        default: return .heavy
        }
    }

    // MARK: - Center autofocus
    func setAutofocusToCenter() {
        guard let device = captureDevice, device.isFocusPointOfInterestSupported, device.isFocusModeSupported(.continuousAutoFocus) else { return }
        do {
            try device.lockForConfiguration()
            device.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
        } catch {
            print("Could not configure autofocus: \(error)")
        }
    }
}