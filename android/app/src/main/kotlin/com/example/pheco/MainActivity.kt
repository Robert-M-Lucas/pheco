package com.example.pheco

import android.content.Context
import android.media.MediaScannerConnection
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {

    private val channel = "com.example.pheco/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

//        val updater = FlutterUpdater(flutterEngine, channel);

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->

            if (call.method == "getImages") {

//                val label = call.argument<String>("label")

// Code to print the label using the SDK
                val count = call.argument<Int>("count")
                result.success(getImages(count))

            }
            else if (call.method == "deleteMediaFile") {
                val path = call.argument<String>("path")
                    ?: throw IllegalArgumentException("Expected path for deleteMediaFile")
                deleteMediaFile(path)
                result.success(null)
            }
            else if (call.method == "rescanMedia") {
                val path = call.argument<String>("path")
                rescanMediaStore(result, path)
            }
            else {

                result.notImplemented()

            }

        }
    }

    private fun rescanMediaStore(result: MethodChannel.Result, path: String?) {
        val path = path ?: "/storage/emulated/0/"
        MediaScannerHelper(context, path, result)
    }

    private fun getImages(count: Int?): List<String> {
//        val galleryImageUrls = mutableListOf<Uri>()
        val galleryImagePaths = mutableListOf<String>()
        val columns = arrayOf(MediaStore.Images.Media._ID, MediaStore.Images.Media.DATA, MediaStore.Images.Media.DISPLAY_NAME)
        val orderBy = MediaStore.Images.Media.DATE_TAKEN

        applicationContext.contentResolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI, columns,
            null, null, if (count == null) "$orderBy DESC" else "$orderBy DESC LIMIT $count"
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndex(MediaStore.Images.Media._ID)
            val dataColumn = cursor.getColumnIndex(MediaStore.Images.Media.DATA)

            while (cursor.moveToNext()) {
//                val id = cursor.getLong(idColumn)
                val data = cursor.getString(dataColumn)
                galleryImagePaths.add(data)

//                galleryImageUrls.add(ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id))
            }
        }

        return galleryImagePaths
    }

    private fun deleteMediaFile(path: String) {
        val contentResolver = context.contentResolver
        val uri = MediaStore.Files.getContentUri("external")

        val selection = "${MediaStore.MediaColumns.DATA} = ?"
        val selectionArgs = arrayOf(path)

        contentResolver.delete(uri, selection, selectionArgs)
    }
}

// Broken
//class FlutterUpdater(private val flutterEngine: FlutterEngine, private val channel: String) {
//    private val uiThreadHandler: Handler = Handler(Looper.getMainLooper())
//
//    fun sendUpdate(update: String) {
//        uiThreadHandler.post {
//            MethodChannel(flutterEngine.dartExecutor, channel).invokeMethod(
//                "updateProgress",
//                update
//            )
//        }
//    }
//}

class MediaScannerHelper(private val mContext: Context, private val mFilePath: String, private val result: MethodChannel.Result) :
    MediaScannerConnection.MediaScannerConnectionClient {
    private val mScanner: MediaScannerConnection?

    init {
        mScanner = MediaScannerConnection(mContext, this)
        mScanner.connect()

    }

    override fun onMediaScannerConnected() {
        mScanner?.scanFile(mFilePath, null)
    }

    override fun onScanCompleted(path: String, uri: Uri) {
        Log.d("MediaScanner", "Scan completed for: $path -> Uri: $uri")
        result.success(path)
        mScanner?.disconnect()
    }
}