package com.example.itzmeanjan.traceme;

import android.database.Cursor;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.sqlite.db.SupportSQLiteStatement;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("unchecked")
public final class LocationDao_Impl implements LocationDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter __insertionAdapterOfLocationData;

  private final EntityDeletionOrUpdateAdapter __deletionAdapterOfLocationData;

  public LocationDao_Impl(RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfLocationData = new EntityInsertionAdapter<LocationData>(__db) {
      @Override
      public String createQuery() {
        return "INSERT OR REPLACE INTO `routes`(`longitude`,`latitude`,`timeStamp`,`routeId`) VALUES (?,?,?,?)";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, LocationData value) {
        if (value.getLongitude() == null) {
          stmt.bindNull(1);
        } else {
          stmt.bindString(1, value.getLongitude());
        }
        if (value.getLatitude() == null) {
          stmt.bindNull(2);
        } else {
          stmt.bindString(2, value.getLatitude());
        }
        if (value.getTimeStamp() == null) {
          stmt.bindNull(3);
        } else {
          stmt.bindString(3, value.getTimeStamp());
        }
        stmt.bindLong(4, value.getRouteId());
      }
    };
    this.__deletionAdapterOfLocationData = new EntityDeletionOrUpdateAdapter<LocationData>(__db) {
      @Override
      public String createQuery() {
        return "DELETE FROM `routes` WHERE `longitude` = ? AND `latitude` = ? AND `timeStamp` = ?";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, LocationData value) {
        if (value.getLongitude() == null) {
          stmt.bindNull(1);
        } else {
          stmt.bindString(1, value.getLongitude());
        }
        if (value.getLatitude() == null) {
          stmt.bindNull(2);
        } else {
          stmt.bindString(2, value.getLatitude());
        }
        if (value.getTimeStamp() == null) {
          stmt.bindNull(3);
        } else {
          stmt.bindString(3, value.getTimeStamp());
        }
      }
    };
  }

  @Override
  public void insertData(LocationData... location) {
    __db.beginTransaction();
    try {
      __insertionAdapterOfLocationData.insert(location);
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
    }
  }

  @Override
  public void deleteData(LocationData locationData) {
    __db.beginTransaction();
    try {
      __deletionAdapterOfLocationData.handle(locationData);
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
    }
  }

  @Override
  public List<LocationData> getRoutes() {
    final String _sql = "select * from routes";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _cursorIndexOfLongitude = _cursor.getColumnIndexOrThrow("longitude");
      final int _cursorIndexOfLatitude = _cursor.getColumnIndexOrThrow("latitude");
      final int _cursorIndexOfTimeStamp = _cursor.getColumnIndexOrThrow("timeStamp");
      final int _cursorIndexOfRouteId = _cursor.getColumnIndexOrThrow("routeId");
      final List<LocationData> _result = new ArrayList<LocationData>(_cursor.getCount());
      while(_cursor.moveToNext()) {
        final LocationData _item;
        final String _tmpLongitude;
        _tmpLongitude = _cursor.getString(_cursorIndexOfLongitude);
        final String _tmpLatitude;
        _tmpLatitude = _cursor.getString(_cursorIndexOfLatitude);
        final String _tmpTimeStamp;
        _tmpTimeStamp = _cursor.getString(_cursorIndexOfTimeStamp);
        final int _tmpRouteId;
        _tmpRouteId = _cursor.getInt(_cursorIndexOfRouteId);
        _item = new LocationData(_tmpLongitude,_tmpLatitude,_tmpTimeStamp,_tmpRouteId);
        _result.add(_item);
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }

  @Override
  public int getLastUsedRouteId() {
    final String _sql = "select max(routeId) from routes";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _result;
      if(_cursor.moveToFirst()) {
        _result = _cursor.getInt(0);
      } else {
        _result = 0;
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }
}
