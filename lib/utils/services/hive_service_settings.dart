part of 'hive_service.dart';

extension HiveServiceSettings on HiveService {
  static String get _boxName => 'LEXIKON_SETTINGS';

  static Box<Settings> get _box => HiveService.getBox<Settings>(_boxName);

  static Settings? get settings => _box.get(_boxName);

  static Future<void> saveSettings(Settings settings) async {
    await _box.put(_boxName, settings);
  }

}