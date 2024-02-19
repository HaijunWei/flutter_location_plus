package com.haijunwei.location_plus

import android.content.Context
import com.baidu.location.BDAbstractLocationListener
import com.baidu.location.BDLocation
import com.baidu.location.LocationClient
import com.baidu.location.LocationClientOption

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

/** LocationPlusPlugin */
class LocationPlusPlugin: FlutterPlugin, EventChannel.StreamHandler, LocationPlus {
  private var eventSink: EventChannel.EventSink? = null
  private var applicationContext: Context? = null
  private var locationClient : LocationClient? = null
  private var channel: EventChannel? = null
  private var singleLocationManagers: MutableList<SingleLocationManager> = mutableListOf<SingleLocationManager>()

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    LocationClient.setAgreePrivacy(true)
    applicationContext = flutterPluginBinding.applicationContext
    channel = EventChannel(flutterPluginBinding.binaryMessenger, "haijunwei/location_plus_event")
    channel?.setStreamHandler(this)
    LocationPlus.setUp(flutterPluginBinding.binaryMessenger, this)
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel?.setStreamHandler(null)
    locationClient?.stop()
    locationClient = null
  }

  override fun startUpdatingLocation() {
    locationClient = LocationClient(applicationContext)
    locationClient?.registerLocationListener(object: BDAbstractLocationListener() {
      override fun onReceiveLocation(location : BDLocation?) {
        if (location != null) {
          val l = Location(
                  location.latitude,
                  location.longitude,
                  location.country,
                  location.province,
                  location.city,
                  location.district)
          eventSink?.success(l.toList())
        }
      }
    })
    locationClient?.start()
  }

  override fun stopUpdatingLocation() {
    locationClient?.stop()
    locationClient = null
  }

  override fun requestSingleLocation(callback: (kotlin.Result<Location>) -> Unit) {
    if (applicationContext == null) { return }
    val manager = SingleLocationManager(applicationContext!!, callback) {
      singleLocationManagers.remove(it)
    }
    singleLocationManagers.add(manager)
    manager.startUpdatingLocation()
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }
}

class SingleLocationManager(
        private var context: Context,
        var callback: (Result<Location>) -> Unit,
        var onDone: (SingleLocationManager) -> Boolean) {

  private var locationClient: LocationClient = LocationClient(context)

  init {
    var option = LocationClientOption()
    option.setIsNeedAddress(true)
    locationClient.locOption = option
    locationClient.registerLocationListener(object: BDAbstractLocationListener() {
      override fun onReceiveLocation(location : BDLocation?) {
        completion(location)
      }
    });

  }

  fun startUpdatingLocation() {
    locationClient.start()
  }

  private fun completion(location : BDLocation?) {
    if (location != null) {
      val l = Location(
              location.latitude,
              location.longitude,
              location.country,
              location.province,
              location.city,
              location.district)
      callback(Result.success(l))
    } else {
      callback(Result.failure(Exception("定位出错")))
    }
    locationClient.stop()
    onDone(this)
  }
}