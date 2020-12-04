/*
Static fields to access compile time app config
 */
class AppConfig {
  // read compile-time variables defined by --dart-define
  // "const" is needed to make it work
  static const apiUrl = const String.fromEnvironment('API_URL'); // ignore: unnecessary_const
  static const deleteDataAtStartup = String.fromEnvironment('DELETE_DATA_AT_STARTUP') == 'TRUE' ? true : false;
}
