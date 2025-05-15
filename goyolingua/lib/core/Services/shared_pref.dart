import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper {
  static const String userIdKey = "USERKEY";
  static const String userNameKey = "USERNAMEKEY";
  static const String userEmailKey = "USEREMAILKEY";
  static const String userImageKey = "USERIMAGEKEY";
  static const String userUserNameKey = "USERUSERNAMEKEY";

  static const String userIdiomaAprender = "USERIDIOMAAPRENDER";
  static const String userIdiomaOrigen = "USERIDIOMAORIGEN";
  static const String userEresMaestro = "ERESMAESTRO";
  static const String userSexo = "USERSEXO";

  // SETTERS
  Future<bool> saveUserId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, value);
  }

  Future<bool> saveUserDisplayName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userNameKey, value);
  }

  Future<bool> saveUserEmail(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, value);
  }

  Future<bool> saveUserImage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userImageKey, value);
  }

  Future<bool> saveUserUserName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userUserNameKey, value);
  }

  Future<bool> saveUserIdiomaAprender(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdiomaAprender, value);
  }

  Future<bool> saveUserIdiomaOrigen(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdiomaOrigen, value);
  }

  Future<bool> saveUserSexo(String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(userSexo, value);
  }

  Future<bool> saveUserEresMaestro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(userEresMaestro, value);
  }

  // GETTERS
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey);
  }

  static Future<String?> getUserDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userImageKey);
  }

  static Future<String?> getUserUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userUserNameKey);
  }

  static Future<String?> getUserIdiomaAprender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdiomaAprender);
  }

  static Future<String?> getUserIdiomaOrigen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdiomaOrigen);
  }

  static Future<bool?> getUserEresMaestro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userEresMaestro);
  }

  static Future<String?> getUserSexo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(userSexo);
  }

  //Limpiar cuando se cierra sesion
  Future<bool> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // Eliminar todos los datos relacionados con el usuario
      await prefs.remove(userIdKey);
      await prefs.remove(userNameKey);
      await prefs.remove(userEmailKey);
      await prefs.remove(userImageKey);
      await prefs.remove(userUserNameKey);
      await prefs.remove(userIdiomaAprender);
      await prefs.remove(userIdiomaOrigen);
      await prefs.remove(userEresMaestro);
      await prefs.remove(userSexo);

      return true; // Indica que la limpieza fue exitosa
    } catch (e) {
      return false; // Indica que hubo un error
    }
  }
}
