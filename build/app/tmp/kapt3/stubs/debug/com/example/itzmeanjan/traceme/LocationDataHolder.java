package com.example.itzmeanjan.traceme;

import java.lang.System;

@kotlin.Metadata(mv = {1, 1, 13}, bv = {1, 0, 3}, k = 1, d1 = {"\u00008\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0006\n\u0002\b\u0002\n\u0002\u0010\t\n\u0002\b\u0002\n\u0002\u0010\u0007\n\u0002\b\u0006\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\b\n\u0002\b7\n\u0002\u0010\u000b\n\u0002\b\u0004\b\u0086\b\u0018\u00002\u00020\u0001Bw\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0006\u0010\u0004\u001a\u00020\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0006\u0012\b\u0010\u0007\u001a\u0004\u0018\u00010\u0003\u0012\b\u0010\b\u001a\u0004\u0018\u00010\t\u0012\b\u0010\n\u001a\u0004\u0018\u00010\t\u0012\b\u0010\u000b\u001a\u0004\u0018\u00010\t\u0012\b\u0010\f\u001a\u0004\u0018\u00010\t\u0012\b\u0010\r\u001a\u0004\u0018\u00010\t\u0012\b\u0010\u000e\u001a\u0004\u0018\u00010\t\u0012\b\u0010\u000f\u001a\u0004\u0018\u00010\u0010\u0012\b\u0010\u0011\u001a\u0004\u0018\u00010\u0012\u00a2\u0006\u0002\u0010\u0013J\t\u0010;\u001a\u00020\u0003H\u00c6\u0003J\u0010\u0010<\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u000b\u0010=\u001a\u0004\u0018\u00010\u0010H\u00c6\u0003J\u0010\u0010>\u001a\u0004\u0018\u00010\u0012H\u00c6\u0003\u00a2\u0006\u0002\u0010-J\t\u0010?\u001a\u00020\u0003H\u00c6\u0003J\t\u0010@\u001a\u00020\u0006H\u00c6\u0003J\u0010\u0010A\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003\u00a2\u0006\u0002\u0010\u001aJ\u0010\u0010B\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u0010\u0010C\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u0010\u0010D\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u0010\u0010E\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u0010\u0010F\u001a\u0004\u0018\u00010\tH\u00c6\u0003\u00a2\u0006\u0002\u0010\u0015J\u0098\u0001\u0010G\u001a\u00020\u00002\b\b\u0002\u0010\u0002\u001a\u00020\u00032\b\b\u0002\u0010\u0004\u001a\u00020\u00032\b\b\u0002\u0010\u0005\u001a\u00020\u00062\n\b\u0002\u0010\u0007\u001a\u0004\u0018\u00010\u00032\n\b\u0002\u0010\b\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\n\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\u000b\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\f\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\r\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\u000e\u001a\u0004\u0018\u00010\t2\n\b\u0002\u0010\u000f\u001a\u0004\u0018\u00010\u00102\n\b\u0002\u0010\u0011\u001a\u0004\u0018\u00010\u0012H\u00c6\u0001\u00a2\u0006\u0002\u0010HJ\u0013\u0010I\u001a\u00020J2\b\u0010K\u001a\u0004\u0018\u00010\u0001H\u00d6\u0003J\t\u0010L\u001a\u00020\u0012H\u00d6\u0001J\t\u0010M\u001a\u00020\u0010H\u00d6\u0001R\u001e\u0010\u000b\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b\u0014\u0010\u0015\"\u0004\b\u0016\u0010\u0017R\u001e\u0010\u0007\u001a\u0004\u0018\u00010\u0003X\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u001d\u001a\u0004\b\u0019\u0010\u001a\"\u0004\b\u001b\u0010\u001cR\u001e\u0010\b\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b\u001e\u0010\u0015\"\u0004\b\u001f\u0010\u0017R\u001e\u0010\r\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b \u0010\u0015\"\u0004\b!\u0010\u0017R\u001a\u0010\u0004\u001a\u00020\u0003X\u0086\u000e\u00a2\u0006\u000e\n\u0000\u001a\u0004\b\"\u0010#\"\u0004\b$\u0010%R\u001a\u0010\u0002\u001a\u00020\u0003X\u0086\u000e\u00a2\u0006\u000e\n\u0000\u001a\u0004\b&\u0010#\"\u0004\b\'\u0010%R\u001c\u0010\u000f\u001a\u0004\u0018\u00010\u0010X\u0086\u000e\u00a2\u0006\u000e\n\u0000\u001a\u0004\b(\u0010)\"\u0004\b*\u0010+R\u001e\u0010\u0011\u001a\u0004\u0018\u00010\u0012X\u0086\u000e\u00a2\u0006\u0010\n\u0002\u00100\u001a\u0004\b,\u0010-\"\u0004\b.\u0010/R\u001e\u0010\n\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b1\u0010\u0015\"\u0004\b2\u0010\u0017R\u001e\u0010\u000e\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b3\u0010\u0015\"\u0004\b4\u0010\u0017R\u001a\u0010\u0005\u001a\u00020\u0006X\u0086\u000e\u00a2\u0006\u000e\n\u0000\u001a\u0004\b5\u00106\"\u0004\b7\u00108R\u001e\u0010\f\u001a\u0004\u0018\u00010\tX\u0086\u000e\u00a2\u0006\u0010\n\u0002\u0010\u0018\u001a\u0004\b9\u0010\u0015\"\u0004\b:\u0010\u0017\u00a8\u0006N"}, d2 = {"Lcom/example/itzmeanjan/traceme/LocationDataHolder;", "", "longitude", "", "latitude", "time", "", "altitude", "bearing", "", "speed", "accuracy", "verticalAccuracy", "bearingAccuracy", "speedAccuracy", "provider", "", "satelliteCount", "", "(DDJLjava/lang/Double;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/String;Ljava/lang/Integer;)V", "getAccuracy", "()Ljava/lang/Float;", "setAccuracy", "(Ljava/lang/Float;)V", "Ljava/lang/Float;", "getAltitude", "()Ljava/lang/Double;", "setAltitude", "(Ljava/lang/Double;)V", "Ljava/lang/Double;", "getBearing", "setBearing", "getBearingAccuracy", "setBearingAccuracy", "getLatitude", "()D", "setLatitude", "(D)V", "getLongitude", "setLongitude", "getProvider", "()Ljava/lang/String;", "setProvider", "(Ljava/lang/String;)V", "getSatelliteCount", "()Ljava/lang/Integer;", "setSatelliteCount", "(Ljava/lang/Integer;)V", "Ljava/lang/Integer;", "getSpeed", "setSpeed", "getSpeedAccuracy", "setSpeedAccuracy", "getTime", "()J", "setTime", "(J)V", "getVerticalAccuracy", "setVerticalAccuracy", "component1", "component10", "component11", "component12", "component2", "component3", "component4", "component5", "component6", "component7", "component8", "component9", "copy", "(DDJLjava/lang/Double;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/Float;Ljava/lang/String;Ljava/lang/Integer;)Lcom/example/itzmeanjan/traceme/LocationDataHolder;", "equals", "", "other", "hashCode", "toString", "app_debug"})
public final class LocationDataHolder {
    private double longitude;
    private double latitude;
    private long time;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Double altitude;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float bearing;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float speed;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float accuracy;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float verticalAccuracy;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float bearingAccuracy;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Float speedAccuracy;
    @org.jetbrains.annotations.Nullable()
    private java.lang.String provider;
    @org.jetbrains.annotations.Nullable()
    private java.lang.Integer satelliteCount;
    
    public final double getLongitude() {
        return 0.0;
    }
    
    public final void setLongitude(double p0) {
    }
    
    public final double getLatitude() {
        return 0.0;
    }
    
    public final void setLatitude(double p0) {
    }
    
    public final long getTime() {
        return 0L;
    }
    
    public final void setTime(long p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Double getAltitude() {
        return null;
    }
    
    public final void setAltitude(@org.jetbrains.annotations.Nullable()
    java.lang.Double p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getBearing() {
        return null;
    }
    
    public final void setBearing(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getSpeed() {
        return null;
    }
    
    public final void setSpeed(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getAccuracy() {
        return null;
    }
    
    public final void setAccuracy(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getVerticalAccuracy() {
        return null;
    }
    
    public final void setVerticalAccuracy(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getBearingAccuracy() {
        return null;
    }
    
    public final void setBearingAccuracy(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float getSpeedAccuracy() {
        return null;
    }
    
    public final void setSpeedAccuracy(@org.jetbrains.annotations.Nullable()
    java.lang.Float p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.String getProvider() {
        return null;
    }
    
    public final void setProvider(@org.jetbrains.annotations.Nullable()
    java.lang.String p0) {
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Integer getSatelliteCount() {
        return null;
    }
    
    public final void setSatelliteCount(@org.jetbrains.annotations.Nullable()
    java.lang.Integer p0) {
    }
    
    public LocationDataHolder(double longitude, double latitude, long time, @org.jetbrains.annotations.Nullable()
    java.lang.Double altitude, @org.jetbrains.annotations.Nullable()
    java.lang.Float bearing, @org.jetbrains.annotations.Nullable()
    java.lang.Float speed, @org.jetbrains.annotations.Nullable()
    java.lang.Float accuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float verticalAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float bearingAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float speedAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.String provider, @org.jetbrains.annotations.Nullable()
    java.lang.Integer satelliteCount) {
        super();
    }
    
    public final double component1() {
        return 0.0;
    }
    
    public final double component2() {
        return 0.0;
    }
    
    public final long component3() {
        return 0L;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Double component4() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component5() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component6() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component7() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component8() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component9() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Float component10() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.String component11() {
        return null;
    }
    
    @org.jetbrains.annotations.Nullable()
    public final java.lang.Integer component12() {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    public final com.example.itzmeanjan.traceme.LocationDataHolder copy(double longitude, double latitude, long time, @org.jetbrains.annotations.Nullable()
    java.lang.Double altitude, @org.jetbrains.annotations.Nullable()
    java.lang.Float bearing, @org.jetbrains.annotations.Nullable()
    java.lang.Float speed, @org.jetbrains.annotations.Nullable()
    java.lang.Float accuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float verticalAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float bearingAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.Float speedAccuracy, @org.jetbrains.annotations.Nullable()
    java.lang.String provider, @org.jetbrains.annotations.Nullable()
    java.lang.Integer satelliteCount) {
        return null;
    }
    
    @org.jetbrains.annotations.NotNull()
    @java.lang.Override()
    public java.lang.String toString() {
        return null;
    }
    
    @java.lang.Override()
    public int hashCode() {
        return 0;
    }
    
    @java.lang.Override()
    public boolean equals(@org.jetbrains.annotations.Nullable()
    java.lang.Object p0) {
        return false;
    }
}