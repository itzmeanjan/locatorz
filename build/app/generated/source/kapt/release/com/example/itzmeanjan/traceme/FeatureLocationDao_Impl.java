package com.example.itzmeanjan.traceme;

import android.database.Cursor;
import androidx.room.EntityDeletionOrUpdateAdapter;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.SharedSQLiteStatement;
import androidx.sqlite.db.SupportSQLiteStatement;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.ArrayList;
import java.util.List;

@SuppressWarnings("unchecked")
public final class FeatureLocationDao_Impl implements FeatureLocationDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter __insertionAdapterOfFeatureLocationData;

  private final EntityDeletionOrUpdateAdapter __deletionAdapterOfFeatureLocationData;

  private final SharedSQLiteStatement __preparedStmtOfClearTable;

  public FeatureLocationDao_Impl(RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfFeatureLocationData = new EntityInsertionAdapter<FeatureLocationData>(__db) {
      @Override
      public String createQuery() {
        return "INSERT OR REPLACE INTO `featureLocation`(`featureLocationId`,`featureId`,`longitude`,`latitude`,`altitude`,`timeStamp`) VALUES (nullif(?, 0),?,?,?,?,?)";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, FeatureLocationData value) {
        stmt.bindLong(1, value.getFeatureLocationId());
        stmt.bindLong(2, value.getFeatureId());
        if (value.getLongitude() == null) {
          stmt.bindNull(3);
        } else {
          stmt.bindString(3, value.getLongitude());
        }
        if (value.getLatitude() == null) {
          stmt.bindNull(4);
        } else {
          stmt.bindString(4, value.getLatitude());
        }
        if (value.getAltitude() == null) {
          stmt.bindNull(5);
        } else {
          stmt.bindString(5, value.getAltitude());
        }
        if (value.getTimeStamp() == null) {
          stmt.bindNull(6);
        } else {
          stmt.bindString(6, value.getTimeStamp());
        }
      }
    };
    this.__deletionAdapterOfFeatureLocationData = new EntityDeletionOrUpdateAdapter<FeatureLocationData>(__db) {
      @Override
      public String createQuery() {
        return "DELETE FROM `featureLocation` WHERE `featureLocationId` = ?";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, FeatureLocationData value) {
        stmt.bindLong(1, value.getFeatureLocationId());
      }
    };
    this.__preparedStmtOfClearTable = new SharedSQLiteStatement(__db) {
      @Override
      public String createQuery() {
        final String _query = "delete from featureLocation";
        return _query;
      }
    };
  }

  @Override
  public void insertData(FeatureLocationData... featureLocation) {
    __db.beginTransaction();
    try {
      __insertionAdapterOfFeatureLocationData.insert(featureLocation);
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
    }
  }

  @Override
  public void deleteFeatureLocation(FeatureLocationData featureLocation) {
    __db.beginTransaction();
    try {
      __deletionAdapterOfFeatureLocationData.handle(featureLocation);
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
    }
  }

  @Override
  public void clearTable() {
    final SupportSQLiteStatement _stmt = __preparedStmtOfClearTable.acquire();
    __db.beginTransaction();
    try {
      _stmt.executeUpdateDelete();
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
      __preparedStmtOfClearTable.release(_stmt);
    }
  }

  @Override
  public List<FeatureLocationData> getFeatureLocations() {
    final String _sql = "select * from featureLocation";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _cursorIndexOfFeatureLocationId = _cursor.getColumnIndexOrThrow("featureLocationId");
      final int _cursorIndexOfFeatureId = _cursor.getColumnIndexOrThrow("featureId");
      final int _cursorIndexOfLongitude = _cursor.getColumnIndexOrThrow("longitude");
      final int _cursorIndexOfLatitude = _cursor.getColumnIndexOrThrow("latitude");
      final int _cursorIndexOfAltitude = _cursor.getColumnIndexOrThrow("altitude");
      final int _cursorIndexOfTimeStamp = _cursor.getColumnIndexOrThrow("timeStamp");
      final List<FeatureLocationData> _result = new ArrayList<FeatureLocationData>(_cursor.getCount());
      while(_cursor.moveToNext()) {
        final FeatureLocationData _item;
        final int _tmpFeatureLocationId;
        _tmpFeatureLocationId = _cursor.getInt(_cursorIndexOfFeatureLocationId);
        final int _tmpFeatureId;
        _tmpFeatureId = _cursor.getInt(_cursorIndexOfFeatureId);
        final String _tmpLongitude;
        _tmpLongitude = _cursor.getString(_cursorIndexOfLongitude);
        final String _tmpLatitude;
        _tmpLatitude = _cursor.getString(_cursorIndexOfLatitude);
        final String _tmpAltitude;
        _tmpAltitude = _cursor.getString(_cursorIndexOfAltitude);
        final String _tmpTimeStamp;
        _tmpTimeStamp = _cursor.getString(_cursorIndexOfTimeStamp);
        _item = new FeatureLocationData(_tmpFeatureLocationId,_tmpFeatureId,_tmpLongitude,_tmpLatitude,_tmpAltitude,_tmpTimeStamp);
        _result.add(_item);
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }

  @Override
  public List<FeatureLocationData> getFeatureLocationById(int featureId) {
    final String _sql = "select * from featureLocation where featureId = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindLong(_argIndex, featureId);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _cursorIndexOfFeatureLocationId = _cursor.getColumnIndexOrThrow("featureLocationId");
      final int _cursorIndexOfFeatureId = _cursor.getColumnIndexOrThrow("featureId");
      final int _cursorIndexOfLongitude = _cursor.getColumnIndexOrThrow("longitude");
      final int _cursorIndexOfLatitude = _cursor.getColumnIndexOrThrow("latitude");
      final int _cursorIndexOfAltitude = _cursor.getColumnIndexOrThrow("altitude");
      final int _cursorIndexOfTimeStamp = _cursor.getColumnIndexOrThrow("timeStamp");
      final List<FeatureLocationData> _result = new ArrayList<FeatureLocationData>(_cursor.getCount());
      while(_cursor.moveToNext()) {
        final FeatureLocationData _item;
        final int _tmpFeatureLocationId;
        _tmpFeatureLocationId = _cursor.getInt(_cursorIndexOfFeatureLocationId);
        final int _tmpFeatureId;
        _tmpFeatureId = _cursor.getInt(_cursorIndexOfFeatureId);
        final String _tmpLongitude;
        _tmpLongitude = _cursor.getString(_cursorIndexOfLongitude);
        final String _tmpLatitude;
        _tmpLatitude = _cursor.getString(_cursorIndexOfLatitude);
        final String _tmpAltitude;
        _tmpAltitude = _cursor.getString(_cursorIndexOfAltitude);
        final String _tmpTimeStamp;
        _tmpTimeStamp = _cursor.getString(_cursorIndexOfTimeStamp);
        _item = new FeatureLocationData(_tmpFeatureLocationId,_tmpFeatureId,_tmpLongitude,_tmpLatitude,_tmpAltitude,_tmpTimeStamp);
        _result.add(_item);
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }
}
