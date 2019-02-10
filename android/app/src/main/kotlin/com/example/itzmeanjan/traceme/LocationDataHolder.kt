package com.example.itzmeanjan.traceme

import android.location.Location
import android.os.Build
import com.google.android.gms.location.LocationCallback
import android.location.LocationListener
import android.os.Bundle
import com.google.android.gms.location.LocationResult
import io.flutter.plugin.common.EventChannel

data class LocationDataHolder(var longitude: Double, var latitude: Double, var time: Long, var altitude: Double?, var bearing: Float?, var speed: Float?, var accuracy: Float?, var verticalAccuracy: Float?, var bearingAccuracy: Float?, var speedAccuracy: Float?, var provider: String?, var satelliteCount: Int?)

class MyLocationCallBack(eventSink: EventChannel.EventSink): LocationCallback(){
    private val event = eventSink
    override fun onLocationResult(p0: LocationResult?) {
        if(p0!=null){
            for (location in p0.locations){
                val locationDataHolder = LocationDataHolder(location.longitude,location.latitude,location.time,null,null,null,null,null,null,null,null,null)
                if(location.hasAltitude())
                    locationDataHolder.altitude = location.altitude
                if(location.hasBearing())
                    locationDataHolder.bearing = location.bearing
                if(location.hasSpeed())
                    locationDataHolder.speed = location.speed
                if(location.hasAccuracy())
                    locationDataHolder.accuracy = location.accuracy
                if(Build.VERSION.SDK_INT>= Build.VERSION_CODES.O){
                    if(location.hasVerticalAccuracy())
                        locationDataHolder.verticalAccuracy = location.verticalAccuracyMeters
                    if(location.hasBearingAccuracy())
                        locationDataHolder.bearingAccuracy = location.bearingAccuracyDegrees
                    if(location.hasSpeedAccuracy())
                        locationDataHolder.speedAccuracy = location.speedAccuracyMetersPerSecond
                }
                if(location.provider!=null)
                    locationDataHolder.provider = location.provider
                if(location.extras!=null)
                    locationDataHolder.satelliteCount = location.extras.getInt("satellites",0)
                event.success(
                        mapOf(
                                "longitude" to locationDataHolder.longitude,
                                "latitude" to locationDataHolder.latitude,
                                "time" to locationDataHolder.time,
                                "altitude" to locationDataHolder.altitude,
                                "bearing" to locationDataHolder.bearing,
                                "speed" to locationDataHolder.speed,
                                "accuracy" to locationDataHolder.accuracy,
                                "verticalAccuracy" to locationDataHolder.verticalAccuracy,
                                "bearingAccuracy" to locationDataHolder.bearingAccuracy,
                                "speedAccuracy" to locationDataHolder.speedAccuracy,
                                "provider" to locationDataHolder.provider,
                                "satelliteCount" to locationDataHolder.satelliteCount
                        )
                )
            }
        }
    }
}

class MyLocationListener(eventSink: EventChannel.EventSink): LocationListener{
    private val event = eventSink
    override fun onProviderDisabled(provider: String?) {
    }

    override fun onProviderEnabled(provider: String?) {
    }

    override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
    }

    override fun onLocationChanged(location: Location?) {
        if(location!=null){
            val locationDataHolder = LocationDataHolder(location.longitude,location.latitude,location.time,null,null,null,null,null,null,null,null,null)
            if(location.hasAltitude())
                locationDataHolder.altitude = location.altitude
            if(location.hasBearing())
                locationDataHolder.bearing = location.bearing
            if(location.hasSpeed())
                locationDataHolder.speed = location.speed
            if(location.hasAccuracy())
                locationDataHolder.accuracy = location.accuracy
            if(Build.VERSION.SDK_INT>= Build.VERSION_CODES.O){
                if(location.hasVerticalAccuracy())
                    locationDataHolder.verticalAccuracy = location.verticalAccuracyMeters
                if(location.hasBearingAccuracy())
                    locationDataHolder.bearingAccuracy = location.bearingAccuracyDegrees
                if(location.hasSpeedAccuracy())
                    locationDataHolder.speedAccuracy = location.speedAccuracyMetersPerSecond
            }
            if(location.provider!=null)
                locationDataHolder.provider = location.provider
            if(location.extras!=null)
                locationDataHolder.satelliteCount = location.extras.getInt("satellites",0)
            event.success(
                    mapOf(
                            "longitude" to locationDataHolder.longitude,
                            "latitude" to locationDataHolder.latitude,
                            "time" to locationDataHolder.time,
                            "altitude" to locationDataHolder.altitude,
                            "bearing" to locationDataHolder.bearing,
                            "speed" to locationDataHolder.speed,
                            "accuracy" to locationDataHolder.accuracy,
                            "verticalAccuracy" to locationDataHolder.verticalAccuracy,
                            "bearingAccuracy" to locationDataHolder.bearingAccuracy,
                            "speedAccuracy" to locationDataHolder.speedAccuracy,
                            "provider" to locationDataHolder.provider,
                            "satelliteCount" to locationDataHolder.satelliteCount
                    )
            )
        }
    }
}
