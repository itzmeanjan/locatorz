package com.example.itzmeanjan.traceme;

import androidx.room.DatabaseConfiguration;
import androidx.room.InvalidationTracker;
import androidx.room.RoomOpenHelper;
import androidx.room.RoomOpenHelper.Delegate;
import androidx.room.util.TableInfo;
import androidx.room.util.TableInfo.Column;
import androidx.room.util.TableInfo.ForeignKey;
import androidx.room.util.TableInfo.Index;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.sqlite.db.SupportSQLiteOpenHelper;
import androidx.sqlite.db.SupportSQLiteOpenHelper.Callback;
import androidx.sqlite.db.SupportSQLiteOpenHelper.Configuration;
import java.lang.IllegalStateException;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.HashMap;
import java.util.HashSet;

@SuppressWarnings("unchecked")
public final class FeatureDataManager_Impl extends FeatureDataManager {
  private volatile FeatureDao _featureDao;

  private volatile FeatureLocationDao _featureLocationDao;

  @Override
  protected SupportSQLiteOpenHelper createOpenHelper(DatabaseConfiguration configuration) {
    final SupportSQLiteOpenHelper.Callback _openCallback = new RoomOpenHelper(configuration, new RoomOpenHelper.Delegate(1) {
      @Override
      public void createAllTables(SupportSQLiteDatabase _db) {
        _db.execSQL("CREATE TABLE IF NOT EXISTS `features` (`featureId` INTEGER NOT NULL, `featureName` TEXT NOT NULL, `featureDescription` TEXT NOT NULL, `featureType` TEXT NOT NULL, PRIMARY KEY(`featureId`))");
        _db.execSQL("CREATE TABLE IF NOT EXISTS `featureLocation` (`featureLocationId` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `featureId` INTEGER NOT NULL, `longitude` TEXT NOT NULL, `latitude` TEXT NOT NULL, `altitude` TEXT NOT NULL, `timeStamp` TEXT NOT NULL)");
        _db.execSQL("CREATE TABLE IF NOT EXISTS room_master_table (id INTEGER PRIMARY KEY,identity_hash TEXT)");
        _db.execSQL("INSERT OR REPLACE INTO room_master_table (id,identity_hash) VALUES(42, \"967599f3cc2c2c160a8aa4ce33c8c7fa\")");
      }

      @Override
      public void dropAllTables(SupportSQLiteDatabase _db) {
        _db.execSQL("DROP TABLE IF EXISTS `features`");
        _db.execSQL("DROP TABLE IF EXISTS `featureLocation`");
      }

      @Override
      protected void onCreate(SupportSQLiteDatabase _db) {
        if (mCallbacks != null) {
          for (int _i = 0, _size = mCallbacks.size(); _i < _size; _i++) {
            mCallbacks.get(_i).onCreate(_db);
          }
        }
      }

      @Override
      public void onOpen(SupportSQLiteDatabase _db) {
        mDatabase = _db;
        internalInitInvalidationTracker(_db);
        if (mCallbacks != null) {
          for (int _i = 0, _size = mCallbacks.size(); _i < _size; _i++) {
            mCallbacks.get(_i).onOpen(_db);
          }
        }
      }

      @Override
      protected void validateMigration(SupportSQLiteDatabase _db) {
        final HashMap<String, TableInfo.Column> _columnsFeatures = new HashMap<String, TableInfo.Column>(4);
        _columnsFeatures.put("featureId", new TableInfo.Column("featureId", "INTEGER", true, 1));
        _columnsFeatures.put("featureName", new TableInfo.Column("featureName", "TEXT", true, 0));
        _columnsFeatures.put("featureDescription", new TableInfo.Column("featureDescription", "TEXT", true, 0));
        _columnsFeatures.put("featureType", new TableInfo.Column("featureType", "TEXT", true, 0));
        final HashSet<TableInfo.ForeignKey> _foreignKeysFeatures = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesFeatures = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoFeatures = new TableInfo("features", _columnsFeatures, _foreignKeysFeatures, _indicesFeatures);
        final TableInfo _existingFeatures = TableInfo.read(_db, "features");
        if (! _infoFeatures.equals(_existingFeatures)) {
          throw new IllegalStateException("Migration didn't properly handle features(com.example.itzmeanjan.traceme.FeatureData).\n"
                  + " Expected:\n" + _infoFeatures + "\n"
                  + " Found:\n" + _existingFeatures);
        }
        final HashMap<String, TableInfo.Column> _columnsFeatureLocation = new HashMap<String, TableInfo.Column>(6);
        _columnsFeatureLocation.put("featureLocationId", new TableInfo.Column("featureLocationId", "INTEGER", true, 1));
        _columnsFeatureLocation.put("featureId", new TableInfo.Column("featureId", "INTEGER", true, 0));
        _columnsFeatureLocation.put("longitude", new TableInfo.Column("longitude", "TEXT", true, 0));
        _columnsFeatureLocation.put("latitude", new TableInfo.Column("latitude", "TEXT", true, 0));
        _columnsFeatureLocation.put("altitude", new TableInfo.Column("altitude", "TEXT", true, 0));
        _columnsFeatureLocation.put("timeStamp", new TableInfo.Column("timeStamp", "TEXT", true, 0));
        final HashSet<TableInfo.ForeignKey> _foreignKeysFeatureLocation = new HashSet<TableInfo.ForeignKey>(0);
        final HashSet<TableInfo.Index> _indicesFeatureLocation = new HashSet<TableInfo.Index>(0);
        final TableInfo _infoFeatureLocation = new TableInfo("featureLocation", _columnsFeatureLocation, _foreignKeysFeatureLocation, _indicesFeatureLocation);
        final TableInfo _existingFeatureLocation = TableInfo.read(_db, "featureLocation");
        if (! _infoFeatureLocation.equals(_existingFeatureLocation)) {
          throw new IllegalStateException("Migration didn't properly handle featureLocation(com.example.itzmeanjan.traceme.FeatureLocationData).\n"
                  + " Expected:\n" + _infoFeatureLocation + "\n"
                  + " Found:\n" + _existingFeatureLocation);
        }
      }
    }, "967599f3cc2c2c160a8aa4ce33c8c7fa", "c3e02d608c52a8bff1e8dbcf321f5e4b");
    final SupportSQLiteOpenHelper.Configuration _sqliteConfig = SupportSQLiteOpenHelper.Configuration.builder(configuration.context)
        .name(configuration.name)
        .callback(_openCallback)
        .build();
    final SupportSQLiteOpenHelper _helper = configuration.sqliteOpenHelperFactory.create(_sqliteConfig);
    return _helper;
  }

  @Override
  protected InvalidationTracker createInvalidationTracker() {
    return new InvalidationTracker(this, "features","featureLocation");
  }

  @Override
  public void clearAllTables() {
    super.assertNotMainThread();
    final SupportSQLiteDatabase _db = super.getOpenHelper().getWritableDatabase();
    try {
      super.beginTransaction();
      _db.execSQL("DELETE FROM `features`");
      _db.execSQL("DELETE FROM `featureLocation`");
      super.setTransactionSuccessful();
    } finally {
      super.endTransaction();
      _db.query("PRAGMA wal_checkpoint(FULL)").close();
      if (!_db.inTransaction()) {
        _db.execSQL("VACUUM");
      }
    }
  }

  @Override
  public FeatureDao getFeatureDao() {
    if (_featureDao != null) {
      return _featureDao;
    } else {
      synchronized(this) {
        if(_featureDao == null) {
          _featureDao = new FeatureDao_Impl(this);
        }
        return _featureDao;
      }
    }
  }

  @Override
  public FeatureLocationDao getFeatureLocationDao() {
    if (_featureLocationDao != null) {
      return _featureLocationDao;
    } else {
      synchronized(this) {
        if(_featureLocationDao == null) {
          _featureLocationDao = new FeatureLocationDao_Impl(this);
        }
        return _featureLocationDao;
      }
    }
  }
}
