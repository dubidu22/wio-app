import Foundation

/// Keeps the app's data out of iCloud backup (D-63, D-72, D-347).
///
/// The database, pictures, recordings and upload files all live in
/// Application Support (path_provider's `getApplicationSupportDirectory`).
/// The flag on the folder excludes everything in it, including files made
/// later. Capture temp files live in `tmp/`, which iOS never backs up.
enum BackupExclusion {
  /// Creates Application Support if needed and excludes it. Runs at launch,
  /// before any Dart code (AppDelegate).
  @discardableResult
  static func excludeAppData(_ files: FileManager = .default) throws -> URL {
    let folder = try files.url(
      for: .applicationSupportDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    try exclude(folder)
    return folder
  }

  /// Sets `isExcludedFromBackup` on [url].
  static func exclude(_ url: URL) throws {
    var target = url
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try target.setResourceValues(values)
  }

  /// Reads the flag back (tests).
  static func isExcluded(_ url: URL) throws -> Bool {
    try url.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup ?? false
  }
}
