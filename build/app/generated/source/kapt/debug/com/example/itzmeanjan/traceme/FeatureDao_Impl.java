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
public final class FeatureDao_Impl implements FeatureDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter __insertionAdapterOfFeatureData;

  private final EntityDeletionOrUpdateAdapter __deletionAdapterOfFeatureData;

  private final SharedSQLiteStatement __preparedStmtOfClearTable;

  public FeatureDao_Impl(RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfFeatureData = new EntityInsertionAdapter<FeatureData>(__db) {
      @Override
      public String createQuery() {
        return "INSERT OR REPLACE INTO `features`(`featureId`,`featureName`,`featureDescription`,`featureType`) VALUES (?,?,?,?)";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, FeatureData value) {
        stmt.bindLong(1, value.getFeatureId());
        if (value.getFeatureName() == null) {
          stmt.bindNull(2);
        } else {
          stmt.bindString(2, value.getFeatureName());
        }
        if (value.getFeatureDescription() == null) {
          stmt.bindNull(3);
        } else {
          stmt.bindString(3, value.getFeatureDescription());
        }
        if (value.getFeatureType() == null) {
          stmt.bindNull(4);
        } else {
          stmt.bindString(4, value.getFeatureType());
        }
      }
    };
    this.__deletionAdapterOfFeatureData = new EntityDeletionOrUpdateAdapter<FeatureData>(__db) {
      @Override
      public String createQuery() {
        return "DELETE FROM `features` WHERE `featureId` = ?";
      }

      @Override
      public void bind(SupportSQLiteStatement stmt, FeatureData value) {
        stmt.bindLong(1, value.getFeatureId());
      }
    };
    this.__preparedStmtOfClearTable = new SharedSQLiteStatement(__db) {
      @Override
      public String createQuery() {
        final String _query = "delete from features";
        return _query;
      }
    };
  }

  @Override
  public void insertData(FeatureData feature) {
    __db.beginTransaction();
    try {
      __insertionAdapterOfFeatureData.insert(feature);
      __db.setTransactionSuccessful();
    } finally {
      __db.endTransaction();
    }
  }

  @Override
  public void deleteFeature(FeatureData feature) {
    __db.beginTransaction();
    try {
      __deletionAdapterOfFeatureData.handle(feature);
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
  public int getLastUsedFeatureId() {
    final String _sql = "select max(featureId) from features";
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

  @Override
  public List<FeatureData> getFeatures() {
    final String _sql = "select * from features";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _cursorIndexOfFeatureId = _cursor.getColumnIndexOrThrow("featureId");
      final int _cursorIndexOfFeatureName = _cursor.getColumnIndexOrThrow("featureName");
      final int _cursorIndexOfFeatureDescription = _cursor.getColumnIndexOrThrow("featureDescription");
      final int _cursorIndexOfFeatureType = _cursor.getColumnIndexOrThrow("featureType");
      final List<FeatureData> _result = new ArrayList<FeatureData>(_cursor.getCount());
      while(_cursor.moveToNext()) {
        final FeatureData _item;
        final int _tmpFeatureId;
        _tmpFeatureId = _cursor.getInt(_cursorIndexOfFeatureId);
        final String _tmpFeatureName;
        _tmpFeatureName = _cursor.getString(_cursorIndexOfFeatureName);
        final String _tmpFeatureDescription;
        _tmpFeatureDescription = _cursor.getString(_cursorIndexOfFeatureDescription);
        final String _tmpFeatureType;
        _tmpFeatureType = _cursor.getString(_cursorIndexOfFeatureType);
        _item = new FeatureData(_tmpFeatureId,_tmpFeatureName,_tmpFeatureDescription,_tmpFeatureType);
        _result.add(_item);
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }

  @Override
  public FeatureData getFeatureById(int featureId) {
    final String _sql = "select * from features where featureId = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindLong(_argIndex, featureId);
    final Cursor _cursor = __db.query(_statement);
    try {
      final int _cursorIndexOfFeatureId = _cursor.getColumnIndexOrThrow("featureId");
      final int _cursorIndexOfFeatureName = _cursor.getColumnIndexOrThrow("featureName");
      final int _cursorIndexOfFeatureDescription = _cursor.getColumnIndexOrThrow("featureDescription");
      final int _cursorIndexOfFeatureType = _cursor.getColumnIndexOrThrow("featureType");
      final FeatureData _result;
      if(_cursor.moveToFirst()) {
        final int _tmpFeatureId;
        _tmpFeatureId = _cursor.getInt(_cursorIndexOfFeatureId);
        final String _tmpFeatureName;
        _tmpFeatureName = _cursor.getString(_cursorIndexOfFeatureName);
        final String _tmpFeatureDescription;
        _tmpFeatureDescription = _cursor.getString(_cursorIndexOfFeatureDescription);
        final String _tmpFeatureType;
        _tmpFeatureType = _cursor.getString(_cursorIndexOfFeatureType);
        _result = new FeatureData(_tmpFeatureId,_tmpFeatureName,_tmpFeatureDescription,_tmpFeatureType);
      } else {
        _result = null;
      }
      return _result;
    } finally {
      _cursor.close();
      _statement.release();
    }
  }
}
