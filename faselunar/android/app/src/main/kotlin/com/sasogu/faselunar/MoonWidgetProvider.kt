package com.sasogu.faselunar

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Build
import android.widget.RemoteViews
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.floor

class MoonWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (ACTION_FORCE_UPDATE == intent.action) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, MoonWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val result = MoonWidgetCalculator.calculateNow()
        val views = RemoteViews(context.packageName, R.layout.moon_widget)

        val labelRes = when (result.phase) {
            MoonPhase.NEW -> R.string.moon_phase_new
            MoonPhase.WAXING_CRESCENT -> R.string.moon_phase_waxing_crescent
            MoonPhase.FIRST_QUARTER -> R.string.moon_phase_first_quarter
            MoonPhase.WAXING_GIBBOUS -> R.string.moon_phase_waxing_gibbous
            MoonPhase.FULL -> R.string.moon_phase_full
            MoonPhase.WANING_GIBBOUS -> R.string.moon_phase_waning_gibbous
            MoonPhase.LAST_QUARTER -> R.string.moon_phase_last_quarter
            MoonPhase.WANING_CRESCENT -> R.string.moon_phase_waning_crescent
        }

        views.setTextViewText(R.id.moon_phase_text, context.getString(labelRes))
        views.setTextViewText(
            R.id.moon_illumination_text,
            context.getString(R.string.moon_widget_illumination, result.illumination * 100.0),
        )

        val sizePx = 128
        val bitmap = MoonWidgetRenderer.render(sizePx, result.illumination, result.isWaxing)
        views.setImageViewBitmap(R.id.moon_image, bitmap)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }

    companion object {
        const val ACTION_FORCE_UPDATE = "com.sasogu.faselunar.ACTION_FORCE_UPDATE_WIDGET"

        fun requestUpdate(context: Context) {
            val intent = Intent(context, MoonWidgetProvider::class.java).apply {
                action = ACTION_FORCE_UPDATE
            }
            context.sendBroadcast(intent)
        }

        fun requestUpdate(context: Context, appWidgetIds: IntArray) {
            val intent = Intent(context, MoonWidgetProvider::class.java).apply {
                action = ACTION_FORCE_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
            }
            context.sendBroadcast(intent)
        }
    }
}

enum class MoonPhase {
    NEW,
    WAXING_CRESCENT,
    FIRST_QUARTER,
    WAXING_GIBBOUS,
    FULL,
    WANING_GIBBOUS,
    LAST_QUARTER,
    WANING_CRESCENT,
}

data class MoonWidgetResult(
    val illumination: Double,
    val isWaxing: Boolean,
    val phase: MoonPhase,
)

object MoonWidgetCalculator {
    private const val SYNODIC_MONTH_DAYS = 29.53058867

    // Same reference as the Flutter code: New moon around 2000-01-06 18:14 UTC.
    private const val REF_NEW_MOON_UTC_MS = 947182440000L

    fun calculateNow(nowUtcMs: Long = System.currentTimeMillis()): MoonWidgetResult {
        val ageDays = ageDays(nowUtcMs)
        val phaseAngle = 2.0 * PI * (ageDays / SYNODIC_MONTH_DAYS)
        val illumination = 0.5 * (1.0 - cos(phaseAngle))

        // Waxing for first half of cycle.
        val isWaxing = ageDays < (SYNODIC_MONTH_DAYS / 2.0)

        val phase = bucketPhase(ageDays)
        return MoonWidgetResult(
            illumination = illumination.coerceIn(0.0, 1.0),
            isWaxing = isWaxing,
            phase = phase,
        )
    }

    private fun ageDays(nowUtcMs: Long): Double {
        val deltaMs = nowUtcMs - REF_NEW_MOON_UTC_MS
        val deltaDays = deltaMs.toDouble() / (1000.0 * 60.0 * 60.0 * 24.0)
        val cycle = deltaDays / SYNODIC_MONTH_DAYS
        val frac = cycle - floor(cycle)
        return frac * SYNODIC_MONTH_DAYS
    }

    private fun bucketPhase(ageDays: Double): MoonPhase {
        // 8 buckets around the synodic month (simple, calendar-precision).
        // Boundaries roughly match the Flutter implementation.
        return when {
            ageDays < 1.0 || ageDays > (SYNODIC_MONTH_DAYS - 1.0) -> MoonPhase.NEW
            ageDays < 6.382646 -> MoonPhase.WAXING_CRESCENT
            ageDays < 8.382646 -> MoonPhase.FIRST_QUARTER
            ageDays < 13.765292 -> MoonPhase.WAXING_GIBBOUS
            ageDays < 15.765292 -> MoonPhase.FULL
            ageDays < 21.147938 -> MoonPhase.WANING_GIBBOUS
            ageDays < 23.147938 -> MoonPhase.LAST_QUARTER
            else -> MoonPhase.WANING_CRESCENT
        }
    }
}

object MoonWidgetRenderer {
    fun render(sizePx: Int, illumination: Double, isWaxing: Boolean): Bitmap {
        val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)

        val center = sizePx / 2f
        val radius = sizePx / 2f

        // Background (transparent). Some launchers add their own widget background.
        canvas.drawColor(Color.TRANSPARENT)

        val darkPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#0B1023")
            style = Paint.Style.FILL
        }
        val lightPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#F6F1D1")
            style = Paint.Style.FILL
        }
        val outlinePaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.parseColor("#40FFFFFF")
            style = Paint.Style.STROKE
            strokeWidth = (sizePx * 0.03f).coerceAtLeast(2f)
        }

        val clamped = illumination.coerceIn(0.0, 1.0)

        // Base: dark then light full disc.
        canvas.drawCircle(center, center, radius, darkPaint)
        canvas.drawCircle(center, center, radius, lightPaint)

        // Cut shadow circle to create phase.
        val shift = (clamped * radius * 2.0).toFloat()
        val offsetX = if (isWaxing) -shift else shift
        canvas.drawCircle(center + offsetX, center, radius, darkPaint)

        // Outline.
        canvas.drawCircle(center, center, radius - outlinePaint.strokeWidth / 2f, outlinePaint)

        return bitmap
    }
}
