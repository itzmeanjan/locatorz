package com.example.itzmeanjan.traceme;

import java.lang.System;

@androidx.room.Dao()
@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u0000,\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\b\n\u0000\n\u0002\u0010 \n\u0002\b\u0002\n\u0002\u0010\u0011\n\u0002\b\u0002\bg\u0018\u00002\u00020\u0001J\u0010\u0010\u0002\u001a\u00020\u00032\u0006\u0010\u0004\u001a\u00020\u0005H\'J\b\u0010\u0006\u001a\u00020\u0007H\'J\u000e\u0010\b\u001a\b\u0012\u0004\u0012\u00020\u00050\tH\'J!\u0010\n\u001a\u00020\u00032\u0012\u0010\u000b\u001a\n\u0012\u0006\b\u0001\u0012\u00020\u00050\f\"\u00020\u0005H\'\u00a2\u0006\u0002\u0010\r\u00a8\u0006\u000e"}, d2 = {"Lcom/example/itzmeanjan/traceme/LocationDao;", "", "deleteData", "", "locationData", "Lcom/example/itzmeanjan/traceme/LocationData;", "getLastUsedRouteId", "", "getRoutes", "", "insertData", "location", "", "([Lcom/example/itzmeanjan/traceme/LocationData;)V", "app_debug"})
public abstract interface LocationDao {
    
    @androidx.room.Insert(onConflict = androidx.room.OnConflictStrategy.REPLACE)
    public abstract void insertData(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.LocationData... location);
    
    @androidx.room.Delete()
    public abstract void deleteData(@org.jetbrains.annotations.NotNull()
    com.example.itzmeanjan.traceme.LocationData locationData);
    
    @org.jetbrains.annotations.NotNull()
    @androidx.room.Query(value = "select * from routes")
    public abstract java.util.List<com.example.itzmeanjan.traceme.LocationData> getRoutes();
    
    @androidx.room.Query(value = "select max(routeId) from routes")
    public abstract int getLastUsedRouteId();
}