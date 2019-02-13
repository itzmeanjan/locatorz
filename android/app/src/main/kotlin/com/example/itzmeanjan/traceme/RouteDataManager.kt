package com.example.itzmeanjan.traceme

import androidx.room.*


@Entity(tableName = "routes")
data class LocationData(
        @ColumnInfo(name = "longitude") var longitude: Double, @ColumnInfo(name = "latitude") var latitude: Double, @ColumnInfo(name = "timeStamp") var timeStamp: Int,
        @ColumnInfo(name = "accuracy") var accuracy: Double?, @ColumnInfo(name = "altitude") var altitude: Double?, @ColumnInfo(name = "routeId") var routeId: Int
){
    @PrimaryKey(autoGenerate = true) var coordinateId: Int = 0
}

@Dao
interface LocationDao{

    @Insert
    fun insertData(vararg location: LocationData)

    @Delete
    fun deleteData(locationData: LocationData)

    @Query("select * from routes")
    fun getRoutes(): List<LocationData>
}

@Database(entities = [LocationData::class], version = 1)
abstract class RouteDataManager: RoomDatabase(){
    abstract fun locationDao(): LocationDao
}
