// chat_utils.dart
class ChatUtils {
  static String getChatRoomIdByUsername(String a, String b) {
    // Compara los strings directamente (Dart compara strings lexicográficamente)
    if (a.compareTo(b) < 0) {
      return "$a\_$b";
    } else {
      return "$b\_$a";
    }
  }
}
