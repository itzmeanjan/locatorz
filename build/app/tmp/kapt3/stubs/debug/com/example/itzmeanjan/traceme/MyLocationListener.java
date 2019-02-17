package com.example.itzmeanjan.traceme;

import java.lang.System;

@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u00004\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0003\n\u0002\u0010\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\b\u0002\n\u0002\u0010\u000e\n\u0002\b\u0003\n\u0002\u0010\b\n\u0000\n\u0002\u0018\u0002\n\u0000\u0018\u00002\u00020\u0001B\r\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0002\u0010\u0004J\u0012\u0010\u0006\u001a\u00020\u00072\b\u0010\b\u001a\u0004\u0018\u00010\tH\u0016J\u0012\u0010\n\u001a\u00020\u00072\b\u0010\u000b\u001a\u0004\u0018\u00010\fH\u0016J\u0012\u0010\r\u001a\u00020\u00072\b\u0010\u000b\u001a\u0004\u0018\u00010\fH\u0016J$\u0010\u000e\u001a\u00020\u00072\b\u0010\u000b\u001a\u0004\u0018\u00010\f2\u0006\u0010\u000f\u001a\u00020\u00102\b\u0010\u0011\u001a\u0004\u0018\u00010\u0012H\u0016R\u000e\u0010\u0005\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000\u00a8\u0006\u0013"}, d2 = {"Lcom/example/itzmeanjan/traceme/MyLocationListener;", "Landroid/location/LocationListener;", "eventSink", "Lio/flutter/plugin/common/EventChannel$EventSink;", "(Lio/flutter/plugin/common/EventChannel$EventSink;)V", "event", "onLocationChanged", "", "location", "Landroid/location/Location;", "onProviderDisabled", "provider", "", "onProviderEnabled", "onStatusChanged", "status", "", "extras", "Landroid/os/Bundle;", "app_debug"})
public final class MyLocationListener implements android.location.LocationListener {
    private final io.flutter.plugin.common.EventChannel.EventSink event = null;
    
    @java.lang.Override()
    public void onProviderDisabled(@org.jetbrains.annotations.Nullable()
    java.lang.String provider) {
    }
    
    @java.lang.Override()
    public void onProviderEnabled(@org.jetbrains.annotations.Nullable()
    java.lang.String provider) {
    }
    
    @java.lang.Override()
    public void onStatusChanged(@org.jetbrains.annotations.Nullable()
    java.lang.String provider, int status, @org.jetbrains.annotations.Nullable()
    android.os.Bundle extras) {
    }
    
    @java.lang.Override()
    public void onLocationChanged(@org.jetbrains.annotations.Nullable()
    android.location.Location location) {
    }
    
    public MyLocationListener(@org.jetbrains.annotations.NotNull()
    io.flutter.plugin.common.EventChannel.EventSink eventSink) {
        super();
    }
}