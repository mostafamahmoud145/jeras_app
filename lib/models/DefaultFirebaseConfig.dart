import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions? get platformOptions {
    // if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '1:511589229811:ios:39f3096a32e73c3b9dc386',
        apiKey: 'AIzaSyAZ9B_jnmkYC-HmcNAPZ8OxeiRsltBTof4',
        projectId: 'app-jeras',
        authDomain: "app-jeras.firebaseapp.com",
        messagingSenderId: '511589229811',
        iosBundleId: 'com.app.jeras',
        iosClientId: '511589229811-0o3p6t9pbpgrgofm5qe4l8mr680j9b86.apps.googleusercontent.com',
        androidClientId:'511589229811-0ukpfaibpp2o3dg69dbb1im7ao4bge1q.apps.googleusercontent.com',
        databaseURL: "https://app-jeras-default-rtdb.europe-west1.firebasedatabase.app",
        storageBucket: 'app-jeras.appspot.com',
          measurementId: "G-XZ7F8NV4EH"
      );
    // } else {
    //   // Android
    //   log("Analytics Dart-only initializer doesn't work on Android, please make sure to add the config file.");
    //
    //   return null;
    // }
  }
}
