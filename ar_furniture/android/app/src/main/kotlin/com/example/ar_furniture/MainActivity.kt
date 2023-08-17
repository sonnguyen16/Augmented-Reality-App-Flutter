package com.example.ar_furniture

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.ar_furniture"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                if (call.method == "openJavaScreen") {
                    val model = call.arguments as String
                    openJavaScreen(model)
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun openJavaScreen( model: String) {
        val intent = Intent(this, ArActivity::class.java)
        intent.putExtra("model", model)
        startActivity(intent)
    }
}
