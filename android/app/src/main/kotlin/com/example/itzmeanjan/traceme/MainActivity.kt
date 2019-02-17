package com.example.itzmeanjan.traceme

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.AsyncTask
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
    // up to this place
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
                "storeRoute" -> { // stores route data into local SQLite database
                    val db = Room.databaseBuilder(applicationContext, RouteDataManager::class.java, "routeDb.db").build()
                    val routeStoredCallback = object : RouteStoredCallback {
                        override fun failure() {
                            db.close()
                            result.success(0)
                        }

                        override fun success() {
                            db.close()
                            result.success(1)
                        }
                    }
                    val routeId: Int? = methodCall.argument<Int>("routeId")
                    val route: List<Map<String, String>>? = methodCall.argument<List<Map<String, String>>>("route")
                    if (route == null)
                        routeStoredCallback.failure()
                    else {
                        val data: MutableList<LocationData> = mutableListOf()
                        route.forEach {
                            data.add(
                                    LocationData(
                                            longitude = it.getValue("longitude"),
                                            latitude = it.getValue("latitude"),
                                            timeStamp = it.getValue("timeStamp"),
                                            routeId = routeId!!
                                    )
                            )
                        }
                        val myAsyncTask = MyAsyncTaskForStoreRoute(db.locationDao(), routeStoredCallback)
                        myAsyncTask.execute(
                                *data.toTypedArray()
                        )
                    }
                }
                "getLastUsedRouteId" -> { // fetches last used routeId from database, which is passed to storeRoute and used for identifying a certain route
                    val db = Room.databaseBuilder(applicationContext,RouteDataManager::class.java,"routeDb.db").build()
                    val getLastUsedRouteIdCallBack = object : GetLastUsedRouteIdCallBack {
                        override fun routeIdCallBack(routeId: Int) {
                            db.close()
                            result.success(routeId)
                        }
                    }
                    val myAsyncTaskForGetLastUsedRouteId = MyAsyncTaskForGetLastUsedRouteId(db.locationDao(), getLastUsedRouteIdCallBack)
                    myAsyncTaskForGetLastUsedRouteId.execute()
                }
                "getRoutes" -> { // get all saved routes
                    val db = Room.databaseBuilder(applicationContext,RouteDataManager::class.java,"routeDb.db").build()
                    val getRoutesCallBack = object : GetRoutesCallBack{
                        override fun getRoutes(routes: List<LocationData>) {
                            db.close()
                            val myRoutes: MutableList<Map<String, String>> = mutableListOf()
                            routes.forEach {
                                myRoutes.add(
                                        mapOf(
                                                "longitude" to it.longitude,
                                                "latitude" to it.latitude,
                                                "timeStamp" to it.timeStamp,
                                                "routeId" to it.routeId.toString()
                                        )
                                )
                            }
                            result.success(myRoutes.toList())
                        }
                    }
                    val myAsyncForGetRoutes = MyAsyncForGetRoutes(db.locationDao(), getRoutesCallBack)
                    myAsyncForGetRoutes.execute()
                }
                "storeFeature" -> {
                    val db = Room.databaseBuilder(applicationContext, FeatureDataManager::class.java, "featureDb.db").build()
                    val storeFeatureCallBack = object : StoreFeatureCallBack {
                        override fun failure() {
                            db.close()
                            result.success(0)
                        }

                        override fun success() {
                            db.close()
                            result.success(1)
                        }
                    }
                    val featureId = methodCall.argument<Int>("featureId")
                    val feature = methodCall.argument<List<Map<String, String>>>("feature")
                    if(feature == null)
                        storeFeatureCallBack.failure()
                    else{
                        val tmp: MutableList<FeatureLocationData> = mutableListOf()
                        feature.forEach {
                            tmp.add(FeatureLocationData(
                                    0, featureId!!, it.getValue("longitude"),it.getValue("latitude"),it.getValue("altitude"),it.getValue("timeStamp")
                            ))
                        }
                        val myAsyncTaskForStoreFeature = MyAsyncTaskForStoreFeature(db.getFeatureDao(), FeatureData(featureId!!, feature[0].getValue("featureName"),feature[0].getValue("featureDescription"), feature[0].getValue("featureType")),db.getFeatureLocationDao(), tmp, storeFeatureCallBack)
                        myAsyncTaskForStoreFeature.execute()
                    }
                }
                "getLastUsedFeatureId" -> {
                    val db = Room.databaseBuilder(applicationContext, FeatureDataManager::class.java, "featureDb.db").build()
                    val getLastUsedFeatureIdCallBack = object : GetLastUsedFeatureIdCallBack{
                        override fun featureIdCallBack(featureId: Int) {
                            db.close()
                            result.success(featureId)
                        }
                    }
                    val myAsyncTaskForGetLastUsedFeatureId = MyAsyncTaskForGetLastUsedFeatureId(db.getFeatureDao(), getLastUsedFeatureIdCallBack)
                    myAsyncTaskForGetLastUsedFeatureId.execute()
                }
                "getFeatures" -> {
                    val db = Room.databaseBuilder(applicationContext, FeatureDataManager::class.java, "featureDb.db").build()
                    val getFeaturesCallBack = object : GetFeaturesCallBack{
                        override fun getFeatures(features: Map<String, List<Map<String, String>>>) {
                            db.close()
                            result.success(features)
                        }
                    }
                    val asyncForGetFeatures = MyAsyncTaskForGetFeatures(db.getFeatureDao(),db.getFeatureLocationDao(),getFeaturesCallBack)
                    asyncForGetFeatures.execute()
                }
                "clearFeatures" -> {
                    val db = Room.databaseBuilder(applicationContext, FeatureDataManager::class.java, "featureDb.db").build()
                    val clearFeaturesCallBack = object : ClearFeaturesCallBack{

                        override fun success() {
                            db.close()
                            result.success(1)
                        }
                    }
                    val asyncTaskForClearFeatures = MyAsyncTaskForClearFeatures(db.getFeatureDao(), db.getFeatureLocationDao(), clearFeaturesCallBack)
                    asyncTaskForClearFeatures.execute()
                }
                else -> {
                    //currently not supporting anything else
                }
            }
        }
    }

    class MyAsyncTaskForStoreRoute(private val locationDao: LocationDao, private val routeStoredCallback: RouteStoredCallback): AsyncTask<LocationData, Void, Int>(){
        override fun doInBackground(vararg params: LocationData): Int {
            return try{
                locationDao.insertData(*params)
                1
            }
            catch (e: Exception){
                0
            }
        }

        override fun onPostExecute(result: Int?) {
            super.onPostExecute(result)
            if(result == 1)
                routeStoredCallback.success()
            else
                routeStoredCallback.failure()
        }
    }

    class MyAsyncTaskForGetLastUsedRouteId(private val locationDao: LocationDao, private val getLastUsedRouteIdCallBack: GetLastUsedRouteIdCallBack): AsyncTask<Void, Void, Int>(){
        override fun doInBackground(vararg params: Void?): Int {
            return try{
                locationDao.getLastUsedRouteId()
            }
            catch (e: Exception){
                0
            }
        }

        override fun onPostExecute(result: Int?) {
            super.onPostExecute(result)
            getLastUsedRouteIdCallBack.routeIdCallBack(result!!)
        }
    }

    class MyAsyncForGetRoutes(private val locationDao: LocationDao, private val getRoutesCallBack: GetRoutesCallBack): AsyncTask<Void, Void, List<LocationData>>(){
        override fun doInBackground(vararg params: Void?): List<LocationData> {
            return try{
                locationDao.getRoutes()
            }
            catch (e: Exception){
                listOf()
            }
        }

        override fun onPostExecute(result: List<LocationData>?) {
            super.onPostExecute(result)
            getRoutesCallBack.getRoutes(result!!)
        }
    }

    class MyAsyncTaskForGetLastUsedFeatureId(private val featureDao: FeatureDao, private val getLastUsedFeatureIdCallBack: GetLastUsedFeatureIdCallBack): AsyncTask<Void, Void, Int>(){
        override fun doInBackground(vararg params: Void?): Int {
            return try{
                featureDao.getLastUsedFeatureId()
            }
            catch (e: Exception){
                0
            }
        }

        override fun onPostExecute(result: Int?) {
            super.onPostExecute(result)
            getLastUsedFeatureIdCallBack.featureIdCallBack(result!!)
        }
    }

    class MyAsyncTaskForStoreFeature(private val featureDao: FeatureDao, private val featureData: FeatureData, private val featureLocationDao: FeatureLocationDao, private val featureLocationData: List<FeatureLocationData>, private val storeFeatureCallBack: StoreFeatureCallBack): AsyncTask<Void,Void,Int>(){
        override fun doInBackground(vararg params: Void?): Int {
            return try{
                featureDao.insertData(featureData)
                featureLocationDao.insertData(*featureLocationData.toTypedArray())
                1
            }
            catch (e: Exception){
                0
            }
        }

        override fun onPostExecute(result: Int?) {
            super.onPostExecute(result)
            if(result == 1)
                storeFeatureCallBack.success()
            else
                storeFeatureCallBack.failure()
        }
    }
    
    class MyAsyncTaskForGetFeatures(private val featureDao: FeatureDao, private val featureLocationDao: FeatureLocationDao, private val getFeaturesCallBack: GetFeaturesCallBack): AsyncTask<Void, Void, Map<String, List<Map<String, String>>>>(){
        override fun doInBackground(vararg params: Void?): Map<String, List<Map<String, String>>> {
            return try{
                val features = featureDao.getFeatures()
                val myFeatures: MutableMap<String, List<Map<String, String>>> = mutableMapOf()
                features.forEach {
                    myFeatures[it.featureId.toString()] = featureLocationDao.getFeatureLocationById(it.featureId).map(
                            fun (value: FeatureLocationData): Map<String, String>{
                                return mapOf(
                                        "featureName" to it.featureName,
                                        "featureDescription" to it.featureDescription,
                                        "featureType" to it.featureType,
                                        "longitude" to value.longitude,
                                        "latitude" to value.latitude,
                                        "altitude" to value.altitude,
                                        "timeStamp" to value.timeStamp
                                )
                            }
                    )
                }
                myFeatures.toMap()
            }
            catch (e: Exception){
                mapOf()
            }
        }

        override fun onPostExecute(result: Map<String, List<Map<String, String>>>?) {
            super.onPostExecute(result)
            getFeaturesCallBack.getFeatures(result!!)
        }
    }

    class MyAsyncTaskForClearFeatures(private val featureDao: FeatureDao, private val featureLocationDao: FeatureLocationDao, private val clearFeaturesCallBack: ClearFeaturesCallBack): AsyncTask<Void, Void, Unit>(){
        override fun doInBackground(vararg params: Void?) {
            return try{
                featureDao.clearTable()
                featureLocationDao.clearTable()
            }
            catch (e: Exception){ }
        }

        override fun onPostExecute(result: Unit?) {
            super.onPostExecute(result)
            clearFeaturesCallBack.success()
        }
    }

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

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode,permissions,grantResults)
        when (requestCode) {
            999 -> {
                grantResults.forEachIndexed { index, i ->
                    if (i != PackageManager.PERMISSION_GRANTED)
                        permissionsNotGranted.add(permissions[index])
                }
                if (permissionsNotGranted.contains(android.Manifest.permission.ACCESS_FINE_LOCATION))
                    permissionCallBack?.denied()
                else
                    permissionCallBack?.granted()
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

interface RouteStoredCallback {
    fun success()
    fun failure()
}

interface GetLastUsedRouteIdCallBack {
    fun routeIdCallBack(routeId: Int)
}

interface GetRoutesCallBack {
    fun getRoutes(routes: List<LocationData>)
}

interface GetLastUsedFeatureIdCallBack {
    fun featureIdCallBack(featureId: Int)
}

interface StoreFeatureCallBack {
    fun success()
    fun failure()
}

interface GetFeaturesCallBack {
    fun getFeatures(features: Map<String, List<Map<String, String>>>)
}

interface ClearFeaturesCallBack {
    fun success()
}