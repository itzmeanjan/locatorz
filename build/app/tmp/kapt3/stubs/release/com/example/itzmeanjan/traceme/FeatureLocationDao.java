package com.example.itzmeanjan.traceme;

import java.lang.System;

@androidx.room.Dao()
@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u0000.\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010 \n\u0000\n\u0002\u0010\b\n\u0002\b\u0002\n\u0002\u0010\u0011\n\u0002\b\u0002\bg\u0018\u00002\u00020\u0001J\b\u0010\u0002\u001a\u00020\u0003H\'J\u0010\u0010\u0004\u001a\u00020\u00032\u0006\u0010\u0005\u001a\u00020\u0006H\'J\u0016\u0010\u0007\u001a\b\u0012\u0004\u0012\u00020\u00060\b2\u0006\u0010\t\u001a\u00020\nH\'J\u000e\u0010\u000b\u001a\b\u0012\u0004\u0012\u00020\u00060\bH\'J!\u0010\f\u001a\u00020\u00032\u0012\u0010\u0005\u001a\n\u0012\u0006\b\u0001\u0012\u00020\u00060\r\"\u00020\u0006H\'\u00a2\u0006\u0002\u0010\u000e\u00a8\u0006\u000f"}, d2 = {"Lcom/example/itzmeanjan/traceme/FeatureLocationDao;", "", "clearTable", "", "deleteFeatureLocation", "featureLocation", "Lcom/example/itzmeanjan/traceme/FeatureLocationData;", "getFeatureLocationById", "", "featureId", "", "getFeatureLocations", "insertData", "", "([Lcom/example/itzmeanjan/traceme/FeatureLocationData;)V", "app_release"})
public abstract interface FeatureLocationDao {
    
    @androidx.room.Insert(onConflict = androidx.room.OnConflictStrategy.REPLACE)
    public abstract void insertData(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.FeatureLocationData... featureLocation);
    
    @org.jetbrains.annotations.NotNull()
    @androidx.room.Query(value = "select * from featureLocation")
    public abstract java.util.List<com.example.itzmeanjan.traceme.FeatureLocationData> getFeatureLocations();
    
    @org.jetbrains.annotations.NotNull()
    @androidx.room.Query(value = "select * from featureLocation where featureId = :featureId")
    public abstract java.util.List<com.example.itzmeanjan.traceme.FeatureLocationData> getFeatureLocationById(int featureId);
    
    @androidx.room.Delete()
    public abstract void deleteFeatureLocation(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.FeatureLocationData featureLocation);
    
    @androidx.room.Query(value = "delete from featureLocation")
    public abstract void clearTable();
}