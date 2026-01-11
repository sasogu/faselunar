package com.sasogu.faselunar

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val channelName = "com.sasogu.faselunar/widget"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"updateMoonWidget" -> {
						MoonWidgetProvider.requestUpdate(this)
						result.success(null)
					}

					else -> result.notImplemented()
				}
			}
	}
}
