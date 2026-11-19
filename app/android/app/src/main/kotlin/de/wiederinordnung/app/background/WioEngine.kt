package de.wiederinordnung.app.background

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * The app's one Flutter engine (D-373). The screen and background work use
 * the same engine, so there is one database connection and one sync run at
 * a time. Main thread only.
 */
object WioEngine {
    const val ID = "wio"

    private var activityAttached = false
    private var backgroundRuns = 0
    private var background: BackgroundChannel? = null

    /** True while a background run uses the engine. */
    val busy: Boolean
        get() = backgroundRuns > 0

    /**
     * The engine, made if needed, with plugins and `wio/background`
     * registered but Dart not yet running: the activity then runs `main()`
     * as usual, or [beginBackground] runs it for background work.
     */
    fun obtain(context: Context): FlutterEngine {
        FlutterEngineCache.getInstance().get(ID)?.let { return it }
        val app = context.applicationContext
        val engine = FlutterEngine(app)
        val channel = BackgroundChannel(app, engine.dartExecutor.binaryMessenger)
        background = channel
        engine.addEngineLifecycleListener(
            object : FlutterEngine.EngineLifecycleListener {
                override fun onPreEngineRestart() {}

                override fun onEngineWillDestroy() {
                    FlutterEngineCache.getInstance().remove(ID)
                    if (background === channel) background = null
                }
            },
        )
        FlutterEngineCache.getInstance().put(ID, engine)
        return engine
    }

    /**
     * The channel of a running engine for one background run. Without a
     * screen, `main()` runs with the argument `background`, so nothing is
     * drawn and no run starts by itself (D-381).
     */
    fun beginBackground(context: Context): BackgroundChannel {
        val engine = obtain(context)
        if (!engine.dartExecutor.isExecutingDart) {
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault(),
                listOf("background"),
            )
        }
        backgroundRuns++
        return checkNotNull(background)
    }

    /** A background run ended; without a screen the engine is let go. */
    fun endBackground() {
        backgroundRuns = maxOf(0, backgroundRuns - 1)
        if (backgroundRuns == 0 && !activityAttached) {
            FlutterEngineCache.getInstance().get(ID)?.destroy()
        }
    }

    /** The activity attached to or left the engine. */
    fun activity(attached: Boolean) {
        activityAttached = attached
    }
}
