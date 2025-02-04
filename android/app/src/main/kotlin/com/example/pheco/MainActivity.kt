package com.example.pheco

import android.content.ContentUris
import android.net.Uri
import android.provider.MediaStore
import android.util.Log
import androidx.core.net.toFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    private val CHANNEL = "com.example.pheco/channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->

            if (call.method == "getImages") {

//                val label = call.argument<String>("label")

// Code to print the label using the SDK
                val count = call.argument<Int>("count");
                result.success(getImages(count))

            } else {

                result.notImplemented()

            }

        }

    }

    private fun getImages(count: Int?): List<String> {
//        val galleryImageUrls = mutableListOf<Uri>()
        val galleryImagePaths = mutableListOf<String>();
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
                galleryImagePaths.add(data);

//                galleryImageUrls.add(ContentUris.withAppendedId(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, id))
            }
        }

        return galleryImagePaths
    }
}