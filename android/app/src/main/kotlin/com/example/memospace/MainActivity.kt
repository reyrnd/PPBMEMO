package com.example.memospace

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import kotlin.math.max

class MainActivity : FlutterActivity() {
    private val channelName = "memospace/attachment_picker"
    private var pendingResult: MethodChannel.Result? = null
    private var pendingType: String = "Document"
    private var pendingUseCamera: Boolean = false

    companion object {
        private const val REQ_PICK_ATTACHMENT = 9401
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                if (call.method == "pickAttachment") {
                    if (pendingResult != null) {
                        pendingResult?.success(null)
                        pendingResult = null
                    }
                    val type = call.argument<String>("type") ?: "Document"
                    val useCamera = call.argument<Boolean>("useCamera") ?: false
                    pendingResult = result
                    pendingType = type
                    pendingUseCamera = useCamera
                    launchNativePicker(type, useCamera)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun launchNativePicker(type: String, useCamera: Boolean) {
        try {
            if (useCamera) {
                val cameraIntent = if (type == "Video") {
                    Intent(MediaStore.ACTION_VIDEO_CAPTURE).apply {
                        putExtra(MediaStore.EXTRA_DURATION_LIMIT, 30)
                        putExtra(MediaStore.EXTRA_VIDEO_QUALITY, 1)
                    }
                } else {
                    Intent(MediaStore.ACTION_IMAGE_CAPTURE)
                }
                startActivityForResult(cameraIntent, REQ_PICK_ATTACHMENT)
                return
            }

            val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                when (type) {
                    "Photo" -> {
                        this.type = "image/*"
                    }
                    "Video" -> {
                        this.type = "video/*"
                    }
                    "PDF" -> {
                        this.type = "application/pdf"
                    }
                    else -> {
                        this.type = "*/*"
                        putExtra(
                            Intent.EXTRA_MIME_TYPES,
                            arrayOf(
                                "application/pdf",
                                "application/msword",
                                "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                "application/vnd.ms-excel",
                                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                                "application/vnd.ms-powerpoint",
                                "application/vnd.openxmlformats-officedocument.presentationml.presentation",
                                "text/plain",
                                "application/zip",
                                "*/*"
                            )
                        )
                    }
                }
            }
            startActivityForResult(
                Intent.createChooser(intent, "Select $type"),
                REQ_PICK_ATTACHMENT
            )
        } catch (e: Exception) {
            val res = pendingResult
            pendingResult = null
            res?.error("PICKER_ERROR", e.localizedMessage, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQ_PICK_ATTACHMENT) return

        val callback = pendingResult ?: return
        pendingResult = null

        if (resultCode != Activity.RESULT_OK || data == null) {
            callback.success(null)
            return
        }

        try {
            // Case 1: Camera photo thumbnail bitmap in extras
            val extraBitmap = data.extras?.get("data") as? Bitmap
            if (extraBitmap != null && pendingUseCamera && pendingType == "Photo") {
                val bytes = bitmapToJpegBytes(extraBitmap, 82)
                val base64Str = Base64.encodeToString(bytes, Base64.NO_WRAP)
                val fileName = "Camera_Photo_${System.currentTimeMillis() % 100000}.jpg"
                callback.success(
                    mapOf(
                        "name" to fileName,
                        "sizeBytes" to bytes.size,
                        "type" to "Photo",
                        "dataUrl" to "data:image/jpeg;base64,$base64Str"
                    )
                )
                return
            }

            // Case 2: URI returned from gallery, file picker, or video camera
            val uri: Uri? = data.data
            if (uri == null) {
                callback.success(null)
                return
            }

            var displayName = "${pendingType}_${System.currentTimeMillis() % 100000}"
            var sizeBytes = 0L

            val cursor: Cursor? = contentResolver.query(uri, null, null, null, null)
            cursor?.use { c ->
                if (c.moveToFirst()) {
                    val nameIdx = c.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIdx >= 0) {
                        val n = c.getString(nameIdx)
                        if (!n.isNullOrBlank()) displayName = n
                    }
                    val sizeIdx = c.getColumnIndex(OpenableColumns.SIZE)
                    if (sizeIdx >= 0 && !c.isNull(sizeIdx)) {
                        sizeBytes = c.getLong(sizeIdx)
                    }
                }
            }

            var dataUrl: String? = null
            if (pendingType == "Photo") {
                contentResolver.openInputStream(uri)?.use { input ->
                    val rawBytes = input.readBytes()
                    if (sizeBytes <= 0L) sizeBytes = rawBytes.size.toLong()
                    val decoded = BitmapFactory.decodeByteArray(rawBytes, 0, rawBytes.size)
                    if (decoded != null) {
                        val scaled = scaleBitmapDown(decoded, 720)
                        val jpegBytes = bitmapToJpegBytes(scaled, 78)
                        val b64 = Base64.encodeToString(jpegBytes, Base64.NO_WRAP)
                        dataUrl = "data:image/jpeg;base64,$b64"
                    }
                }
            } else if (pendingType == "Video") {
                try {
                    val retriever = MediaMetadataRetriever()
                    retriever.setDataSource(this, uri)
                    val frame = retriever.frameAtTime
                    retriever.release()
                    if (frame != null) {
                        val scaled = scaleBitmapDown(frame, 640)
                        val jpegBytes = bitmapToJpegBytes(scaled, 75)
                        val b64 = Base64.encodeToString(jpegBytes, Base64.NO_WRAP)
                        dataUrl = "data:image/jpeg;base64,$b64"
                    }
                } catch (_: Exception) {
                }
            }

            if (sizeBytes <= 0L) {
                try {
                    contentResolver.openFileDescriptor(uri, "r")?.use { pfd ->
                        if (pfd.statSize > 0) sizeBytes = pfd.statSize
                    }
                } catch (_: Exception) {
                }
            }
            if (sizeBytes <= 0L) sizeBytes = 1024L * 120L

            if (!displayName.contains('.')) {
                val ext = when (pendingType) {
                    "Photo" -> ".jpg"
                    "Video" -> ".mp4"
                    "PDF" -> ".pdf"
                    else -> ".docx"
                }
                displayName += ext
            }

            callback.success(
                mapOf(
                    "name" to displayName,
                    "sizeBytes" to sizeBytes.toInt(),
                    "type" to pendingType,
                    "dataUrl" to dataUrl
                )
            )
        } catch (e: Exception) {
            callback.error("READ_ERROR", e.localizedMessage, null)
        }
    }

    private fun scaleBitmapDown(bitmap: Bitmap, maxDimension: Int): Bitmap {
        val width = bitmap.width
        val height = bitmap.height
        val largest = max(width, height)
        if (largest <= maxDimension) return bitmap
        val ratio = maxDimension.toFloat() / largest.toFloat()
        val newW = (width * ratio).toInt().coerceAtLeast(1)
        val newH = (height * ratio).toInt().coerceAtLeast(1)
        return Bitmap.createScaledBitmap(bitmap, newW, newH, true)
    }

    private fun bitmapToJpegBytes(bitmap: Bitmap, quality: Int): ByteArray {
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
        return stream.toByteArray()
    }
}
