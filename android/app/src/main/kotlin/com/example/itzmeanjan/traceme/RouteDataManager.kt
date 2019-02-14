package com.example.itzmeanjan.traceme

import androidx.room.*


@Entity(tableName = "routes", primaryKeys = ["longitude", "latitude", "timeStamp"])
data class LocationData(
        @ColumnInfo(name = "longitude") var longitude: String, @ColumnInfo(name = "latitude") var latitude: String, @ColumnInfo(name = "timeStamp") var timeStamp: String,
        @ColumnInfo(name = "routeId") var routeId: Int
)

@Dao
interface LocationDao{

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertData(vararg location: LocationData)

    @Delete
    fun deleteData(locationData: LocationData)

    @Query("select * from routes")
    fun getRoutes(): List<LocationData>

    @Query("select max(routeId) from routes")
    fun getLastUsedRouteId(): Int
}

@Database(entities = [LocationData::class], version = 1)
abstract class RouteDataManager: RoomDatabase(){
    abstract fun locationDao(): LocationDao
}
