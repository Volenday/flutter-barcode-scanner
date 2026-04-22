package com.ahastudio.barcode_scanner_poc

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class BarcodeScannerPocPlugin: FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var result: Result? = null

    companion object {
        private const val SCAN_REQUEST_CODE = 1
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "barcode_scanner_poc")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "scanBarcode") {
            this.result = result
            val intent = Intent(activity, BarcodeScannerActivity::class.java)
            val overlayLabel = call.argument<String>("overlayLabel")?.trim().orEmpty()
            if (overlayLabel.isNotEmpty()) {
                intent.putExtra(BarcodeScannerActivity.EXTRA_OVERLAY_LABEL, overlayLabel)
                @Suppress("UNCHECKED_CAST")
                val styleMap = call.argument<Map<String, Any>>("overlayLabelStyle")
                BarcodeScannerActivity.putStyleExtras(intent, styleMap)
            }
            val closeOnTap = call.argument<Boolean>("overlayLabelCloseOnTap") ?: false
            if (closeOnTap) {
                intent.putExtra(BarcodeScannerActivity.EXTRA_OVERLAY_CLOSE_ON_TAP, true)
            }
            activity?.startActivityForResult(intent, SCAN_REQUEST_CODE)
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activity = null
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == SCAN_REQUEST_CODE) {
            val payload = when (resultCode) {
                Activity.RESULT_OK -> {
                    val outcome = data?.getStringExtra("outcome") ?: "success"
                    when (outcome) {
                        "success" -> {
                            val code = data?.getStringExtra("barcode_value").orEmpty()
                            mapOf("outcome" to "success", "code" to code)
                        }
                        "overlay_back" -> mapOf("outcome" to "overlay_back")
                        else -> mapOf("outcome" to outcome)
                    }
                }
                Activity.RESULT_CANCELED -> {
                    val outcome = data?.getStringExtra("outcome") ?: "cancelled"
                    mapOf("outcome" to outcome)
                }
                else -> mapOf("outcome" to "cancelled")
            }
            result?.success(payload)
            result = null
            return true
        }
        return false
    }
}
