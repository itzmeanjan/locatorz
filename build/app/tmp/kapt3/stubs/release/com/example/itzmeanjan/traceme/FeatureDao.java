package com.example.itzmeanjan.traceme;

import java.lang.System;

@androidx.room.Dao()
@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\b\n\u0000\n\u0002\u0010 \n\u0002\b\u0003\bg\u0018\u00002\u00020\u0001J\b\u0010\u0002\u001a\u00020\u0003H\'J\u0010\u0010\u0004\u001a\u00020\u00032\u0006\u0010\u0005\u001a\u00020\u0006H\'J\u0010\u0010\u0007\u001a\u00020\u00062\u0006\u0010\b\u001a\u00020\tH\'J\u000e\u0010\n\u001a\b\u0012\u0004\u0012\u00020\u00060\u000bH\'J\b\u0010\f\u001a\u00020\tH\'J\u0010\u0010\r\u001a\u00020\u00032\u0006\u0010\u0005\u001a\u00020\u0006H\'\u00a8\u0006\u000e"}, d2 = {"Lcom/example/itzmeanjan/traceme/FeatureDao;", "", "clearTable", "", "deleteFeature", "feature", "Lcom/example/itzmeanjan/traceme/FeatureData;", "getFeatureById", "featureId", "", "getFeatures", "", "getLastUsedFeatureId", "insertData", "app_release"})
public abstract interface FeatureDao {
    
    @androidx.room.Insert(onConflict = androidx.room.OnConflictStrategy.REPLACE)
    public abstract void insertData(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.FeatureData feature);
    
    @androidx.room.Query(value = "select max(featureId) from features")
    public abstract int getLastUsedFeatureId();
    
    @org.jetbrains.annotations.NotNull()
    @androidx.room.Query(value = "select * from features")
    public abstract java.util.List<com.example.itzmeanjan.traceme.FeatureData> getFeatures();
    
    @org.jetbrains.annotations.NotNull()
    @androidx.room.Query(value = "select * from features where featureId = :featureId")
    public abstract com.example.itzmeanjan.traceme.FeatureData getFeatureById(int featureId);
    
    @androidx.room.Delete()
    public abstract void deleteFeature(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.FeatureData feature);
    
    @androidx.room.Query(value = "delete from features")
    public abstract void clearTable();
}