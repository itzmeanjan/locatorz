package com.example.itzmeanjan.traceme

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.room.Room
import com.google.android.gms.common.ConnectionResult.SUCCESS
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val methodChannelName: String = "com.example.itzmeanjan.traceme.locationUpdateMethodChannel"
    private var methodChannel: MethodChannel? = null
    private val eventChannelName: String = "com.example.itzmeanjan.traceme.locationUpdateEventChannel"
    private var eventChannel: EventChannel? = null
    private val permissionsNotGranted: MutableList<String> = mutableListOf()
    private val permissionsToBeGranted: List<String> = listOf(android.Manifest.permission.ACCESS_FINE_LOCATION, android.Manifest.permission.ACCESS_COARSE_LOCATION)
    private var permissionCallBack: PermissionCallBack? = null
    private var locationSettingsCallBack: LocationSettingsCallBack? = null
    // will be used later to control flow of data( location updates ), from platform side to UI
    private var fusedLocationProviderClient: FusedLocationProviderClient? = null
    private var locationManager: LocationManager? = null
    private var locationCallback: MyLocationCallBack? = null
    private var locationListener: MyLocationListener? = null
    private var eventSink: EventChannel.EventSink? = null
    // upto this place
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)
        methodChannel = MethodChannel(flutterView, methodChannelName)
        methodChannel?.setMethodCallHandler { methodCall, result ->
            permissionCallBack = object : PermissionCallBack {
                override fun denied() {
                    result.success(0) // permission not granted
                }

                override fun granted() {
                    result.success(1) // permission granted
                }
            }
            locationSettingsCallBack = object : LocationSettingsCallBack{
                override fun disabled() {
                    result.success(0) // location not enabled by user, notified to UI
                }

                override fun enabled() {
                    result.success(1) // location enabled by user
                }
            }
            when (methodCall.method) {
                "requestPermissions" -> { // invoke this function for requesting different types of permissions
                    requestPermissions()
                }
                "requestLocationPermission" -> { // specializes in requesting location access permission
                    requestPermissions(index = 0)
                }
                "enableLocation" -> { // asks user politely to enable location, if not enabled already
                    enableLocation()
                }
                "startLocationUpdate" -> { // starts location update listening service and sends data to UI using eventChannel
                    eventChannel = EventChannel(flutterView, eventChannelName)
                    result.success(1)
                    eventChannel?.setStreamHandler(
                            object : EventChannel.StreamHandler{
                                override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
                                    if(p1!=null){
                                        eventSink = p1
                                        val arg: String? = methodCall.argument("id")
                                        if(arg == null){
                                            if(isGooglePlayServiceAvailable()){
                                                fusedLocationProviderClient = FusedLocationProviderClient(this@MainActivity)
                                                locationCallback = MyLocationCallBack(eventSink = p1)
                                                if(locationCallback!=null)
                                                    startPlayServiceBasedLocationUpdates(fusedLocationProviderClient!!, locationCallback!!)
                                            }
                                            else{
                                                locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                                                locationListener = MyLocationListener(eventSink = p1)
                                                if(locationListener!=null){
                                                    startLocationManagerBasedLocationUpdates(locationManager!!,LocationManager.GPS_PROVIDER,android.Manifest.permission.ACCESS_FINE_LOCATION,locationListener!!)
                                                    startLocationManagerBasedLocationUpdates(locationManager!!,LocationManager.NETWORK_PROVIDER,android.Manifest.permission.ACCESS_COARSE_LOCATION,locationListener!!)
                                                }
                                            }
                                        }
                                        else{
                                            if(arg == "0"){
                                                if(isGooglePlayServiceAvailable()){
                                                    fusedLocationProviderClient = FusedLocationProviderClient(this@MainActivity)
                                                    locationCallback = MyLocationCallBack(eventSink = p1)
                                                    if(locationCallback!=null)
                                                        startPlayServiceBasedLocationUpdates(fusedLocationProviderClient!!, locationCallback!!)
                                                }
                                            }
                                            else{
                                                locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                                                locationListener = MyLocationListener(eventSink = p1)
                                                if(locationListener!=null){
                                                    startLocationManagerBasedLocationUpdates(locationManager!!,LocationManager.GPS_PROVIDER,android.Manifest.permission.ACCESS_FINE_LOCATION,locationListener!!)
                                                    startLocationManagerBasedLocationUpdates(locationManager!!,LocationManager.NETWORK_PROVIDER,android.Manifest.permission.ACCESS_COARSE_LOCATION,locationListener!!)
                                                }
                                            }
                                        }
                                    }
                                }

                                override fun onCancel(p0: Any?) {
                                    if(locationCallback!=null && fusedLocationProviderClient!=null){
                                        fusedLocationProviderClient?.removeLocationUpdates(locationCallback)
                                        locationCallback = null
                                    }
                                    if(locationListener!=null && locationManager!=null){
                                        locationManager?.removeUpdates(locationListener)
                                        locationListener=null
                                    }
                                }
                            }
                    )
                }
                "stopLocationUpdate" -> { // if you need to stop getting location updates, just invoke this method from UI level
                    if(fusedLocationProviderClient!=null){
                        fusedLocationProviderClient?.removeLocationUpdates(locationCallback)
                        locationCallback = null
                        fusedLocationProviderClient = null
                    }
                    if(locationManager!=null){
                        locationManager?.removeUpdates(locationListener)
                        locationListener = null
                        locationManager = null
                    }
                    if(eventSink!=null)
                        eventSink?.endOfStream()
                    eventChannel=null
                    result.success(1)
                }
                "storeRoute" -> {
                    val routeId  = methodCall.argument<Int>("routeId")
                    val data = methodCall.argument<List<Map<String, Double>>>("route")
                    if(data == null)
                        result.success(0)
                    else{
                        val locationDataList: MutableList<LocationData> = mutableListOf()
                        data.forEach {
                            locationDataList.add(LocationData(longitude = it.getValue("longitude"), latitude = it.getValue("latitude"), timeStamp = it.getValue("timeStamp").toInt(), accuracy = it.getValue("accuracy"), altitude = it.getValue("altitude"), routeId = routeId!!))
                        }
                        val db = Room.databaseBuilder(applicationContext,RouteDataManager::class.java,"routeDb").build()
                        val myExecutor = Executors.newSingleThreadExecutor()
                        myExecutor.execute {
                            db.locationDao().insertData(location = *locationDataList.toTypedArray())
                        }
                        db.close()
                        result.success(1)
                    }
                }
                else -> {
                    //currently not supporting anything else
                }
            }
        }
    }

    /*
    class MyAsyncTask(private val asyncLocationDao: LocationDao): AsyncTask<LocationData,Void,Void>(){

        override fun doInBackground(vararg params: LocationData): Void? {
            asyncLocationDao.insertData(*params)
            return null
        }

    }
    */

    private fun isGooglePlayServiceAvailable(): Boolean{
        return GoogleApiAvailability.getInstance().isGooglePlayServicesAvailable(applicationContext) == SUCCESS
    }

    private fun startPlayServiceBasedLocationUpdates(fusedLocationProviderClient: FusedLocationProviderClient, locationCallback: MyLocationCallBack){
        if(ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED)
            fusedLocationProviderClient.requestLocationUpdates(createLocationRequest(), locationCallback, null)
    }

    private fun startLocationManagerBasedLocationUpdates(locationManager: LocationManager, provider:String, permission: String, locationListener: MyLocationListener){
        if(ContextCompat.checkSelfPermission(this, permission) == PackageManager.PERMISSION_GRANTED)
            locationManager.requestLocationUpdates(provider,5000,1.toFloat(),locationListener)
    }

    private fun requestPermissions(index: Int = -1) {
        val tempList: List<String> = if(index > -1 && index < permissionsToBeGranted.size) {
            listOf(permissionsToBeGranted[index]).filter {
                !isPermissionAvailable(it)
            }
        }
        else{
            permissionsToBeGranted.filter {
                !isPermissionAvailable(it)
            }
        }
        if (tempList.isNotEmpty())
            ActivityCompat.requestPermissions(this, tempList.toTypedArray(), 999)
        else
            permissionCallBack?.granted()
    }

    private fun enableLocation(){
        val locationRequest = createLocationRequest() //creates location requirements request object
        val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest) // location request settings builder
        val client = LocationServices.getSettingsClient(this) //location settings client
        val task = client.checkLocationSettings(builder.build())
        task.addOnSuccessListener {
            locationSettingsCallBack?.enabled()
        }
        task.addOnFailureListener {
            if(it is ResolvableApiException){
                try{
                    it.startResolutionForResult(this@MainActivity, 998)
                }
                catch (sendEx: IntentSender.SendIntentException){
                    locationSettingsCallBack?.disabled()
                }
            }
        }
    }

    private fun createLocationRequest(): LocationRequest{
        return LocationRequest.create().apply {
            interval = 10000
            fastestInterval = 5000
            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when(requestCode){
            998 -> {
                if(resultCode == Activity.RESULT_OK)
                    locationSettingsCallBack?.enabled()
                else
                    locationSettingsCallBack?.disabled()
            }
            else -> {
                // not handling them yet
            }
        }
    }

    private fun isPermissionAvailable(permission: String): Boolean {
        return ContextCompat.checkSelfPermission(applicationContext, permission) == PackageManager.PERMISSION_GRANTED
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?) {
        when (requestCode) {
            999 -> {
                if (grantResults != null && permissions != null) {
                    grantResults.forEachIndexed { index, i ->
                        if (i != PackageManager.PERMISSION_GRANTED)
                            permissionsNotGranted.add(permissions[index])
                    }
                    if (permissionsNotGranted.contains(android.Manifest.permission.ACCESS_FINE_LOCATION))
                        permissionCallBack?.denied()
                    else
                        permissionCallBack?.granted()
                }
            }
            else -> {
                // ignoring anything else
            }
        }
    }
}

interface PermissionCallBack {
    fun granted()
    fun denied()
}

interface LocationSettingsCallBack {
    fun enabled()
    fun disabled()
}

