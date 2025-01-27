package com.musicplayer

import android.os.Build
import androidx.annotation.RequiresApi
import com.facebook.react.ReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.ViewManager

class CustomReactPackage : ReactPackage {

    @RequiresApi(Build.VERSION_CODES.O)
    override fun createNativeModules(reactContext: ReactApplicationContext): List<NativeModule> {
        val modules = mutableListOf<NativeModule>()
        modules.add(AudioEventModule(reactContext))
        modules.add(AudioModule(reactContext))
        return modules
    }

    override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>> {
        return emptyList()
    }
}