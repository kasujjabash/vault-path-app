package com.example.budjar

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.budjar.file_opener"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openFile") {
                val path = call.argument<String>("path")
                if (path != null) {
                    try {
                        openFile(path)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("FILE_OPEN_ERROR", "Unable to open file", e.message)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Path is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun openFile(filePath: String) {
        val file = File(filePath)
        val uri = FileProvider.getUriForFile(this, "${packageName}.fileprovider", file)
        
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK
        }
        
        if (intent.resolveActivity(packageManager) != null) {
            startActivity(intent)
        } else {
            // No PDF viewer app found, try opening as generic file
            val genericIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "*/*")
                flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK
            }
            startActivity(Intent.createChooser(genericIntent, "Open file with"))
        }
    }
}
