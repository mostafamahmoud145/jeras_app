
class AppConstants{
  static const String imagesPath='assets/images/';
  static const String iconsPath='assets/jeras_icons/';
  static const String callsIconsPath='assets/call/';
  static const int maxLines = 3;
  static const int maxLines4 = 4;
  static const int maxLength = 300;
  static const int milliseconds250 = 250;
  static const int milliseconds300 = 300;
  static const int milliseconds150 = 150;
  static const int milliseconds400 = 400;
  static const int milliseconds800 = 800;
  static const int milliseconds1500 = 1500;
  static const int milliseconds6000 = 6000;
  static const int milliseconds2000 = 2000;
  static const int seconds60 = 60;
  static const double letterSpacing = 0.5;

  static const int minutes20 = 20;
  static const int minutes30 = 30;
  static const int minutes60 = 60;
  static const double letterSpacing0_3 = 0.3;
  static const double letterSpacing0_5 = 0.5;
  static const double letterSpacing1 = 1;
  static const double timer50 = 50;
  static const String consultant = 'CONSULTANT';
  static const String user = 'USER';
  static const int kIsWebValue = 500;


  /// Authentication api url & end points.
  static const String authenticationBaseUrl = 'https://apis.jeras.io/';
  static const String loginEndPoint = '${authenticationBaseUrl}login';
  static const String generateOTPEndPoint = '${authenticationBaseUrl}generate-otp';
  static const String verifyOTPEndPoint = '${authenticationBaseUrl}verify-otp';

}