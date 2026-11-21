package com.singhtarun.monvexa

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val SMS_CHANNEL = "com.monvexa/sms"
    private val PERM_CHANNEL = "com.monvexa/permissions"
    private val SMS_PERM_REQUEST_CODE = 101

    private var pendingPermResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Permission Channel ──────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasSmsPermission" -> result.success(hasSmsPermission())
                    "requestSmsPermission" -> {
                        if (hasSmsPermission()) {
                            result.success(true)
                        } else {
                            pendingPermResult = result
                            requestPermissions(
                                arrayOf(Manifest.permission.READ_SMS),
                                SMS_PERM_REQUEST_CODE
                            )
                        }
                    }
                    "openAppSettings" -> {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                        intent.data = Uri.parse("package:${packageName}")
                        startActivity(intent)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // ── SMS Read Channel ────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getInboxSms") {
                    val limit = call.argument<Int>("limit") ?: 300
                    try {
                        val smsList = readInboxSms(limit)
                        Log.d("MonvexaSMS", "readInboxSms returned ${smsList.size} messages")
                        result.success(smsList)
                    } catch (e: Exception) {
                        Log.e("MonvexaSMS", "Error reading inbox SMS", e)
                        result.error("SMS_READ_ERROR", e.localizedMessage, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == SMS_PERM_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingPermResult?.success(granted)
            pendingPermResult = null
        }
    }

    private fun hasSmsPermission(): Boolean =
        checkSelfPermission(Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED

    private fun readInboxSms(limit: Int): List<Map<String, Any?>> {
        val list = mutableListOf<Map<String, Any?>>()
        if (!hasSmsPermission()) {
            Log.w("MonvexaSMS", "hasSmsPermission() returned false")
            return list
        }
        
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date")
        val cursor = contentResolver.query(
            uri,
            projection,
            null,
            null,
            "date DESC LIMIT $limit"
        ) ?: return list

        cursor.use {
            val idCol = it.getColumnIndex("_id")
            val addrCol = it.getColumnIndex("address")
            val bodyCol = it.getColumnIndex("body")
            val dateCol = it.getColumnIndex("date")

            while (it.moveToNext()) {
                val idVal = if (idCol != -1) it.getString(idCol) ?: it.getLong(idCol).toString() else ""
                val addrVal = if (addrCol != -1) it.getString(addrCol) ?: "" else ""
                val bodyVal = if (bodyCol != -1) it.getString(bodyCol) ?: "" else ""
                val dateVal = if (dateCol != -1) it.getLong(dateCol) else 0L

                list.add(
                    mapOf(
                        "id" to idVal,
                        "address" to addrVal,
                        "body" to bodyVal,
                        "date" to dateVal
                    )
                )
            }
        }
        return list
    }
}
