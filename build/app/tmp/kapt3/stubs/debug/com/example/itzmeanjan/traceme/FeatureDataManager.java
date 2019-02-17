package com.example.itzmeanjan.traceme;

import java.lang.System;

@androidx.room.Database(entities = {com.example.itzmeanjan.traceme.FeatureData.class, com.example.itzmeanjan.traceme.FeatureLocationData.class}, version = 1)
@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u0000\u0018\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\b\'\u0018\u00002\u00020\u0001B\u0005\u00a2\u0006\u0002\u0010\u0002J\b\u0010\u0003\u001a\u00020\u0004H&J\b\u0010\u0005\u001a\u00020\u0006H&\u00a8\u0006\u0007"}, d2 = {"Lcom/example/itzmeanjan/traceme/FeatureDataManager;", "Landroidx/room/RoomDatabase;", "()V", "getFeatureDao", "Lcom/example/itzmeanjan/traceme/FeatureDao;", "getFeatureLocationDao", "Lcom/example/itzmeanjan/traceme/FeatureLocationDao;", "app_debug"})
public abstract class FeatureDataManager extends androidx.room.RoomDatabase {
    
    @org.jetbrains.annotations.NotNull()
    public abstract com.example.itzmeanjan.traceme.FeatureDao getFeatureDao();
    
    @org.jetbrains.annotations.NotNull()
    public abstract com.example.itzmeanjan.traceme.FeatureLocationDao getFeatureLocationDao();
    
    public FeatureDataManager() {
        super();
    }
}