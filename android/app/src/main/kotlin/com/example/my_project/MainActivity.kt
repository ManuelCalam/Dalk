package com.dalk.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity
import android.util.Log

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "dalk_notifications"
            val channelName = "Dalk Notifications"
            val channelDescription = "Notificaciones de paseos en Dalk"
            val importance = NotificationManager.IMPORTANCE_HIGH
            
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
                enableLights(true)
                enableVibration(true)
                setShowBadge(true)
                lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
            }
            
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
            
            Log.d("MainActivity", "Canal de notificación creado: $channelId")
            
            // Verificar que el canal se creó correctamente
            val createdChannel = notificationManager.getNotificationChannel(channelId)
            if (createdChannel != null) {
                Log.d("MainActivity", "✅ Canal verificado: ${createdChannel.name}")
                Log.d("MainActivity", "✅ Importancia del canal: ${createdChannel.importance}")
            } else {
                Log.e("MainActivity", "❌ Error: Canal no se pudo crear")
            }
        } else {
            Log.d("MainActivity", "Android version < 26, no se necesita canal")
        }
    }
}
