package com.example.itzmeanjan.traceme

import androidx.room.*

@Entity(tableName = "features", primaryKeys = ["featureId"])
data class FeatureData(
        @ColumnInfo(name = "featureId") var featureId: Int,
        @ColumnInfo(name = "featureName") var featureName: String,
        @ColumnInfo(name = "featureDescription") var featureDescription: String,
        @ColumnInfo(name = "featureType") var featureType: String
)

@Entity(tableName = "featureLocation")
data class FeatureLocationData(
        @PrimaryKey(autoGenerate = true) var featureLocationId: Int,
        @ColumnInfo(name = "featureId") var featureId: Int,
        @ColumnInfo(name = "longitude") var longitude: String,
        @ColumnInfo(name = "latitude") var latitude: String,
        @ColumnInfo(name = "altitude") var altitude: String,
        @ColumnInfo(name = "timeStamp") var timeStamp: String
)


@Dao
interface FeatureDao{
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertData(feature: FeatureData)

    @Query("select max(featureId) from features")
    fun getLastUsedFeatureId(): Int

    @Query("select * from features")
    fun getFeatures(): List<FeatureData>

    @Query("select * from features where featureId = :featureId")
    fun getFeatureById(featureId: Int): FeatureData

    @Delete
    fun deleteFeature(feature: FeatureData)

    @Query("delete from features")
    fun clearTable()
}

@Dao
interface FeatureLocationDao{
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertData(vararg featureLocation: FeatureLocationData)

    @Query("select * from featureLocation")
    fun getFeatureLocations(): List<FeatureLocationData>

    @Query("select * from featureLocation where featureId = :featureId")
    fun getFeatureLocationById(featureId: Int): List<FeatureLocationData>

    @Delete
    fun deleteFeatureLocation(featureLocation: FeatureLocationData)

    @Query("delete from featureLocation")
    fun clearTable()
}

@Database(entities = [FeatureData::class, FeatureLocationData::class], version = 1)
abstract class FeatureDataManager: RoomDatabase(){
    abstract fun getFeatureDao(): FeatureDao

    abstract fun getFeatureLocationDao(): FeatureLocationDao
}