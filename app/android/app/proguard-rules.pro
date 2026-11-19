# Release builds (R8 full mode) remove the no-argument constructors that Room
# opens by reflection. WorkManager's database is a Room database, so without
# this rule the app dies at start in androidx.startup.InitializationProvider:
#   NoSuchMethodException: androidx.work.impl.WorkDatabase_Impl.<init> []
# Found by the launch smoke test (plan 091, issue #91, D-393).
-keep class * extends androidx.room.RoomDatabase { <init>(); }
