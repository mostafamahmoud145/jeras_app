import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAGUAGE_CODE = 'languageCode';
const String THEME = 'THEME';

const List<Locale> supportedLocale = [
  Locale('ar', 'AR'),
  Locale('en', 'US'),
  Locale('es'),
  Locale('nl'),
  Locale('fr','FR'),
  Locale('ca'),
  Locale('zh'),
];

//languages code
const String ENGLISH = 'en';
const String FRENCH = 'fr';
const String ARABIC = 'ar';
const String HINDI = 'hi';
//languages code
const String LIGHT = 'light';
const String DARK = 'dark';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<ThemeData> setTheme(String theme) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(THEME, theme);
  if (theme == "dark")
    return ThemeData.dark().copyWith(
      primaryColor: Color(0xFFFFFFFF),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFFFFFFFF),
      primaryColorDark: Color(0xFFAFD754),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF282B30)),
    );
  else
    return ThemeData.light().copyWith(
      primaryColor: Color(0xFF7b6c94),
      canvasColor: Color(0xFF7b6c94),
      shadowColor: Color(0xFF7b6c94),
      primaryColorDark: Color(0xFF7b6c94),
      colorScheme:
          ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF7b6c94)),
    );
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? await getLocalPhoneLang();
  return _locale(languageCode);
}

Future<String> getLocalPhoneLang() async{
  // الحصول على لغة الجهاز
  String deviceLanguage = PlatformDispatcher.instance.locale.languageCode;
  String lang;
  if (deviceLanguage == "ar") {
    lang = "ar";
  } else if (deviceLanguage == "en") {
    lang = "en";
  } else if (deviceLanguage == "fr") {
    lang = "fr";
  } else {
    lang = "en";
  }

  await setLocale(lang);
  return lang;
}
Future<ThemeData> getTheme() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  
  String themeCode = _prefs.getString(THEME) ?? "light";
  if (themeCode == "dark")
    return ThemeData.dark().copyWith(
      primaryColor: Color(0xFFFFFFFF),
      /* accentColor: Color(0xFF282B30),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFFFFFFFF),
      primaryColorDark:Color(0xFFAFD754),*/
    );
  else
    return ThemeData.light().copyWith(
      primaryColor: Color(0xFF7b6c94),
      /*accentColor: Color(0xFFAFD754),
      canvasColor: Color(0xFFFFD503),
      shadowColor: Color(0xFF000000),
      primaryColorDark:Color(0xFF000000),*/
    );
}

Future<String> getThemeName() async {

  String themeCode = "light"; // _prefs.getString(THEME) ?? "light";
  return themeCode;
}

// Future<bool> getFirstLanch() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//
//   if (prefs.containsKey("firstLaunch")) {
//     return false;
//   } else {
//     await prefs.setBool("firstLaunch", true);
//     return true;
//   }
// }

Future<void> setFirstLanch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setBool("firstLaunch", false);
}

Future<String> getLangCode() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return languageCode;
}

Locale _locale(String languageCode) {
  return supportedLocale.firstWhere(
    (element) => element.languageCode.trim() == languageCode.trim(),
    orElse: () => Locale(ARABIC),
  );
}
