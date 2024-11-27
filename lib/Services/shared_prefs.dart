import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefs{
  void saveSessionId(String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('session_id', sessionId);
    print("Session ID saved: $sessionId");
  }

  void saveTipeUser(String tipe_user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('tipe_user', tipe_user);
    print("User Type saved: $tipe_user");
  }

  Future<String?> getSessionId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('session_id');
  }

  Future<String?> getTipeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tipe_user');
  }

  Future<void> saveUserData(String name, String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    print("User data saved: $name, $email");
  }

  // Mengambil data nama user
  Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  // Mengambil data email user
  Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }


  Future<String?> getSessionIdFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final sessionIdCookie = prefs.getString('session_id');
    print("Session ID saved: $sessionIdCookie");

    if (sessionIdCookie != null) {
      return _extractSessionId(sessionIdCookie);
    }

    return null;
  }

  String? _extractSessionId(String sessionIdCookie) {
    try {
      // Memisahkan bagian cookie menjadi beberapa bagian
      final parts = sessionIdCookie.split(';');
      
      // Melakukan iterasi pada bagian yang dipisahkan
      for (final part in parts) {
        final trimmedPart = part.trim();
        
        // Mencari bagian yang dimulai dengan 'session_id='
        if (trimmedPart.startsWith('session_id=')) {
          // Mengembalikan hanya nilai session_id
          return trimmedPart.split('=')[1];
        }
      }
      return null;
    } catch (e) {
      print('Error extracting session ID: $e');
      return null;
    }
  }

  Future<void> clear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("All user data cleared");
  }
}
