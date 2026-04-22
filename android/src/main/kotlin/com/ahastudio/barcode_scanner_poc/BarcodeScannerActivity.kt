package com.ahastudio.barcode_scanner_poc

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.util.TypedValue
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.annotation.OptIn
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatImageButton
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import com.google.mlkit.vision.barcode.BarcodeScanner
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.barcode.common.Barcode
import com.google.mlkit.vision.common.InputImage
import java.util.concurrent.Executors

class BarcodeScannerActivity : AppCompatActivity() {
    companion object {
        const val EXTRA_OVERLAY_LABEL = "overlay_label"
        const val EXTRA_OVERLAY_CLOSE_ON_TAP = "overlay_close_on_tap"
        const val EXTRA_STYLE_BG = "overlay_style_bg"
        const val EXTRA_STYLE_TEXT = "overlay_style_text"
        const val EXTRA_STYLE_TEXT_SIZE_SP = "overlay_style_text_size_sp"
        const val EXTRA_STYLE_FONT_WEIGHT = "overlay_style_font_weight"
        const val EXTRA_STYLE_PAD_H_DP = "overlay_style_pad_h_dp"
        const val EXTRA_STYLE_PAD_V_DP = "overlay_style_pad_v_dp"
        const val EXTRA_STYLE_RADIUS_DP = "overlay_style_radius_dp"

        fun putStyleExtras(intent: Intent, style: Map<String, Any>?) {
            if (style == null) return
            (style["backgroundColor"] as? Number)?.toInt()?.let { intent.putExtra(EXTRA_STYLE_BG, it) }
            (style["textColor"] as? Number)?.toInt()?.let { intent.putExtra(EXTRA_STYLE_TEXT, it) }
            (style["fontSize"] as? Number)?.toFloat()?.let { intent.putExtra(EXTRA_STYLE_TEXT_SIZE_SP, it) }
            (style["fontWeight"] as? Number)?.toInt()?.let { intent.putExtra(EXTRA_STYLE_FONT_WEIGHT, it) }
            (style["paddingHorizontal"] as? Number)?.toFloat()?.let { intent.putExtra(EXTRA_STYLE_PAD_H_DP, it) }
            (style["paddingVertical"] as? Number)?.toFloat()?.let { intent.putExtra(EXTRA_STYLE_PAD_V_DP, it) }
            (style["borderRadius"] as? Number)?.toFloat()?.let { intent.putExtra(EXTRA_STYLE_RADIUS_DP, it) }
        }
    }

    private lateinit var previewView: PreviewView
    private lateinit var barcodeScanner: BarcodeScanner
    private val cameraExecutor = Executors.newSingleThreadExecutor()
    private val requestCameraPermission = 10

    // Torch / camera control (reserved)
    private var camera: Camera? = null
    private var scanMethodOptions = BarcodeScannerOptions.Builder().setBarcodeFormats(
        Barcode.FORMAT_EAN_8,
        Barcode.FORMAT_EAN_13,
        Barcode.FORMAT_ITF,
        Barcode.FORMAT_CODE_128,
        Barcode.FORMAT_QR_CODE,
        Barcode.FORMAT_DATA_MATRIX
    ).build()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_barcode_scanner)
        previewView = findViewById(R.id.previewView)
        barcodeScanner = BarcodeScanning.getClient(scanMethodOptions)

        onBackPressedDispatcher.addCallback(
            this,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    setResult(
                        Activity.RESULT_OK,
                        Intent().apply { putExtra("outcome", "cancelled") },
                    )
                    finish()
                }
            },
        )

        val overlayRow = findViewById<LinearLayout>(R.id.overlayRow)
        val overlay = findViewById<TextView>(R.id.overlayLabel)
        val backButton = findViewById<AppCompatImageButton>(R.id.overlayBackButton)

        val labelText = intent.getStringExtra(EXTRA_OVERLAY_LABEL)?.trim().orEmpty()
        val closeOnTap = intent.getBooleanExtra(EXTRA_OVERLAY_CLOSE_ON_TAP, false)
        val hasLabel = labelText.isNotEmpty()
        if (hasLabel || closeOnTap) {
            overlayRow.visibility = View.VISIBLE
            if (hasLabel) {
                overlay.text = labelText
                overlay.visibility = View.VISIBLE
                applyOverlayStyleFromIntent(overlay, intent)
            } else {
                overlay.visibility = View.GONE
            }
            if (closeOnTap) {
                backButton.visibility = View.VISIBLE
                backButton.setOnClickListener {
                    setResult(
                        Activity.RESULT_OK,
                        Intent().apply { putExtra("outcome", "overlay_back") },
                    )
                    finish()
                }
            } else {
                backButton.visibility = View.GONE
            }
            ViewCompat.setOnApplyWindowInsetsListener(overlayRow) { v, windowInsets ->
                applyOverlayRowMargins(v as LinearLayout, windowInsets)
                windowInsets
            }
            overlayRow.post { requestOverlayRowMargins(overlayRow) }
        }

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CAMERA), requestCameraPermission)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == requestCameraPermission && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            startCamera()
        } else {
            Toast.makeText(this, "Camera permission denied", Toast.LENGTH_SHORT).show()
            setResult(
                Activity.RESULT_OK,
                Intent().apply { putExtra("outcome", "cancelled") },
            )
            finish()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(this)
        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            val preview = Preview.Builder().build().also {
                it.setSurfaceProvider(previewView.surfaceProvider)
            }
            val imageAnalysis = ImageAnalysis.Builder().build().also {
                it.setAnalyzer(cameraExecutor) { imageProxy ->
                    processImageProxy(imageProxy)
                }
            }
            try {
                cameraProvider.unbindAll()
                camera = cameraProvider.bindToLifecycle(
                    this,
                    CameraSelector.DEFAULT_BACK_CAMERA,
                    preview,
                    imageAnalysis
                )

                // Center autofocus
                val cameraControl = camera!!.cameraControl
                val factory = SurfaceOrientedMeteringPointFactory(
                    previewView.width.toFloat(),
                    previewView.height.toFloat()
                )
                val point = factory.createPoint(
                    previewView.width / 2f,
                    previewView.height / 2f
                )
                val action = FocusMeteringAction.Builder(point).build()
                cameraControl.startFocusAndMetering(action)

                // Zoom (example: 50% linear zoom)
                cameraControl.setLinearZoom(0.5f)

                // Exposure (example: +1 compensation if supported)
                val cameraInfo = camera!!.cameraInfo
                val exposureRange = cameraInfo.exposureState.exposureCompensationRange
                if (exposureRange.contains(1)) {
                    cameraControl.setExposureCompensationIndex(1)
                }

            } catch (exc: Exception) {
                Log.e("BarcodeScanner", "Failed to start camera", exc)
            }
        }, ContextCompat.getMainExecutor(this))
    }

    @OptIn(ExperimentalGetImage::class)
    private fun processImageProxy(imageProxy: ImageProxy) {
        val mediaImage = imageProxy.image
        if (mediaImage != null) {
            val image = InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
            barcodeScanner.process(image)
                .addOnSuccessListener { barcodes ->
                    for (barcode in barcodes) {
                        val value = barcode.rawValue
                        val resultIntent = Intent().apply {
                            putExtra("outcome", "success")
                            putExtra("barcode_value", value)
                        }
                        setResult(Activity.RESULT_OK, resultIntent)
                        finish()
                        break
                    }
                }
                .addOnFailureListener {
                    Log.e("BarcodeScanner", "Failed to process barcode", it)
                }
                .addOnCompleteListener {
                    imageProxy.close()
                }
        } else {
            imageProxy.close()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        cameraExecutor.shutdown()
    }

    private fun applyOverlayStyleFromIntent(tv: TextView, intent: Intent) {
        val d = resources.displayMetrics.density
        val hasBg = intent.hasExtra(EXTRA_STYLE_BG)
        val hasRadius = intent.hasExtra(EXTRA_STYLE_RADIUS_DP)
        if (hasBg || hasRadius) {
            val argb = if (hasBg) {
                intent.getIntExtra(EXTRA_STYLE_BG, 0x00000000)
            } else {
                0x00000000
            }
            val radiusDp = if (hasRadius) {
                intent.getFloatExtra(EXTRA_STYLE_RADIUS_DP, 6f)
            } else {
                6f
            }
            val gd = GradientDrawable()
            gd.setColor(argb)
            gd.cornerRadius = radiusDp * d
            tv.background = gd
        }
        if (intent.hasExtra(EXTRA_STYLE_TEXT)) {
            tv.setTextColor(intent.getIntExtra(EXTRA_STYLE_TEXT, 0xFFFFFFFF.toInt()))
        }
        if (intent.hasExtra(EXTRA_STYLE_TEXT_SIZE_SP)) {
            val sp = intent.getFloatExtra(EXTRA_STYLE_TEXT_SIZE_SP, 14f)
            tv.setTextSize(TypedValue.COMPLEX_UNIT_SP, sp)
        }
        if (intent.hasExtra(EXTRA_STYLE_FONT_WEIGHT)) {
            val w = intent.getIntExtra(EXTRA_STYLE_FONT_WEIGHT, 400)
            tv.typeface = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                Typeface.create(Typeface.DEFAULT, w, false)
            } else {
                Typeface.create(Typeface.DEFAULT, if (w >= 600) Typeface.BOLD else Typeface.NORMAL)
            }
        }
        if (intent.hasExtra(EXTRA_STYLE_PAD_H_DP) || intent.hasExtra(EXTRA_STYLE_PAD_V_DP)) {
            val ph = intent.getFloatExtra(EXTRA_STYLE_PAD_H_DP, 10f) * d
            val pv = intent.getFloatExtra(EXTRA_STYLE_PAD_V_DP, 6f) * d
            tv.setPadding(ph.toInt(), pv.toInt(), ph.toInt(), pv.toInt())
        }
    }

    private fun requestOverlayRowMargins(overlayRow: LinearLayout) {
        val rootInsets = ViewCompat.getRootWindowInsets(overlayRow)
        if (rootInsets == null) {
            overlayRow.post { requestOverlayRowMargins(overlayRow) }
            return
        }
        applyOverlayRowMargins(overlayRow, rootInsets)
    }

    private fun applyOverlayRowMargins(overlayRow: LinearLayout, windowInsets: WindowInsetsCompat) {
        val insetTypes = WindowInsetsCompat.Type.statusBars() or WindowInsetsCompat.Type.displayCutout()
        val insets = windowInsets.getInsets(insetTypes)
        val lp = overlayRow.layoutParams as FrameLayout.LayoutParams
        val baseTop = resources.getDimensionPixelSize(R.dimen.scanner_overlay_margin_top)
        val baseStart = resources.getDimensionPixelSize(R.dimen.scanner_overlay_margin_start)
        lp.topMargin = baseTop + insets.top
        lp.marginStart = baseStart + insets.left
        overlayRow.layoutParams = lp
    }
}