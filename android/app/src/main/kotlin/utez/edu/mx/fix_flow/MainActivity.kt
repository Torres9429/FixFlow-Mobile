package utez.edu.mx.fix_flow

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Canal de los avisos push: el back lo manda como channelId "avisos"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val canal = NotificationChannel("avisos", "Avisos", NotificationManager.IMPORTANCE_HIGH).apply {
                description = "Cambios en tus reportes e incidencias"
            }
            getSystemService(NotificationManager::class.java).createNotificationChannel(canal)
        }
    }
}
