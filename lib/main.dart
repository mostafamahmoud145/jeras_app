import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:jeras/controller/blocs/program_bloc/program_bloc.dart';
import 'package:jeras/pages/home_page.dart';
import 'package:jeras/pages/TechnicalSupportPage.dart';
import 'package:jeras/screens/ConsultantDetailsScreen.dart';
import 'package:jeras/screens/courseDetailsScreen.dart';
import 'package:jeras/screens/languageScreen.dart';
import 'package:jeras/screens/onBoardingScreen.dart';
import 'package:jeras/app/authentication/view/screens/sign_up_screen.dart';
import 'package:jeras/screens/walletScreen.dart';
import 'package:jeras/shared%20preferences/shared_preferences.dart';
import 'package:jeras/widget/responsive.dart';

import '../../repositories/authentication_repository.dart';
import '../../repositories/user_data_repository.dart';
import '../../screens/forceUpdateScreen.dart';
import '../../screens/registerType.dart';
import '../../screens/splash_screen.dart';
import 'Utils/app_life_cycle-observer.dart';
import 'blocs/jitsi_meet/call_cubit/call_cubit.dart';
import 'blocs/jitsi_meet/start_call_screen.dart';
import 'config/app_values.dart';
import 'config/assets_manager.dart';
import 'controller/blocs/account_bloc/account_bloc.dart';
import 'controller/blocs/notification_bloc/notification_bloc.dart';
import 'controller/blocs/replace_video_bloc/cubit.dart';
import 'controller/blocs/replace_video_bloc/state.dart';
import 'controller/blocs/sign_in_bloc/signin_bloc.dart';
import 'controller/blocs/sign_up_bloc/signup_bloc.dart';
import 'localization/language_constants.dart';
import 'localization/localization_methods.dart';
import 'localization/set_localization.dart';
import 'methods/change_user_call_state.dart';
import 'models/DefaultFirebaseConfig.dart';
import 'models/scrool.dart';
import 'screens/home_screen.dart';
import 'services/app_flyer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    setUrlStrategy(PathUrlStrategy());
    await Firebase.initializeApp(
        options: DefaultFirebaseConfig.platformOptions);
  } else {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
  await CashHelper.init();
  AppLifecycleObserver appLifecycleObserver = AppLifecycleObserver();
  appLifecycleObserver.initialize();

  //final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  final AuthenticationRepository authenticationRepository =
      AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  // final WebRtcRepository webRtcRepository = WebRtcRepository();

  if (!kIsWeb) {
    await AppFlyerService().init(FirebaseAuth.instance.currentUser?.uid);
  }

  // runApp(TestWebRTCScreen());
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(
            authenticationRepository: authenticationRepository,
            userDataRepository: userDataRepository,
          ),
        ),
        // BlocProvider<WebRtcBloc>(
        //   create: (context) => WebRtcBloc(
        //
        //      webRtcRepository: webRtcRepository,
        //   ),
        // ),
        BlocProvider<SigninBloc>(
          create: (context) => SigninBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),
        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),

        BlocProvider<ProgramBloc>(
          create: (context) => ProgramBloc(),
        ),
        BlocProvider<CallCubit>(
          create: (context) => CallCubit(),
        ),
        BlocProvider<VideoCubit>(
          create: (context) => VideoCubit(VideoInitialState()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  //final PendingDynamicLinkData? initialLink;
  const MyApp({
    Key? key,
  }) : super(key: key);

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  // final Smartlook smartlook = Smartlook.instance;
  bool isSet = false;
  Locale? _local;
  bool firstLansh = false;
  bool _isCall = false;
  bool _navigatedToCallScreen = false;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void setLocale(Locale locale) {
    setState(() {
      _local = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        _local = locale;
      });
    });

    // getFirstLanch().then((ss) {
    //   setState(() {
    //     firstLansh = ss;
    //   });
    // });

    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    //Check call when open app from terminated
    Future.delayed(Duration(seconds: 1), () {
      checkAndNavigationCallingPage(null, x: 'from init');
    });
  }

  Future<dynamic> getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    //var calls = await CallKeep.instance.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        print('=========================call there is call now');
        return calls[0];
      } else {
        print('=========================noooooo call');
        if (FirebaseAuth.instance.currentUser != null) {
          await changeUserState(
              userId: FirebaseAuth.instance.currentUser!.uid, state: 'closed');
        }
        endCall();
        return null;
      }
    }
  }

  Future<void> checkAndNavigationCallingPage(BuildContext? contexts,
      {String? x}) async {
    print('=========================call checkAndNavigationCallingPage $x');
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      //_navigatedToCallScreen = true;
      _isCall = true;

      if (Platform.isIOS) {
        /// todo: this work
        if (navigatorKey.currentState == null) {
          Navigator.pushNamed(contexts!, '/startCallScreen');
        } else {
          navigatorKey.currentState!.pushNamed(
            '/startCallScreen',
          );
        }
      } else {
        if (contexts == null) {
          navigatorKey.currentState!.pushNamed('/startCallScreen');
        } else {
          Navigator.pushNamed(contexts, '/startCallScreen');
        }
      }
    }
    // }

/////========================================================
//         //if(navigatorKey!= null)
//         //   Navigator.pushNamed(navigatorKey.currentState!.context, '/startCallScreen');
//         // navigatorKey.currentState!.pushNamed('/startCallScreen');
//       }
//     }
  }

  void endCall() {
    _isCall = false;
    //_navigatedToCallScreen = false;
  }

  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (Platform.isAndroid) {
  //     if (state == AppLifecycleState.resumed) {
  //       //Check call when open app from background
  //       checkAndNavigationCallingPage(null, x: 'from resumed');
  //     }
  //   }
  // }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Future<void> initSmartlook() async {
  //   await smartlook.log.enableLogging();
  //   await smartlook.preferences.setProjectKey('f038af5d321189c97f4a34259b09a0d13064bcb4');
  //   await smartlook.start();
  //   smartlook.registerIntegrationListener(CustomIntegrationListener());
  //   await smartlook.preferences.setWebViewEnabled(true);
  //   setState(() {
  //     isSet = true;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    //background 1 screen
    if (this._local == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800]!)),
        ),
      );
    } else {
      Responsive.init(context);

      return MaterialApp(
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        // key: navigatorKey,
        title: 'Jeras',
        locale: _local,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'AR'),
          Locale('fr', 'FR')
        ],
        localizationsDelegates: const [
          SetLocalization.localizationsDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CountryLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocal, supportedLocales) {
          for (var local in supportedLocales) {
            if (local.languageCode == deviceLocal?.languageCode &&
                local.countryCode == deviceLocal?.countryCode) {
              return deviceLocal;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
          fontFamily: getTranslated(context, "Ithra"),
          useMaterial3: true,
          primaryColor: Color(0xFF7b6c94),
          colorScheme: ColorScheme.light(primary: const Color(0xFF7b6c94)),
          canvasColor: Colors.white,
          buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),

        navigatorKey: navigatorKey,
        initialRoute: _isCall ? '/startCallScreen' : '/',
        onGenerateRoute: (RouteSettings routeSettings) {
          Uri url = Uri.parse(routeSettings!.name!);

          if (routeSettings!.name!.contains('conslultant?consultant_id') &&
              url.queryParameters['tap_id'] == null &&
              url.queryParameters['data'] == null) {
            return MaterialPageRoute(
              settings: RouteSettings(
                  name:
                      'conslultant?consultant_id=${url.queryParameters['consultant_id']}',
                  arguments: {
                    "consultant_id": url.queryParameters['consultant_id']
                  }),
              builder: (context) => ConsultantDetailsScreen(
                consoltantId: url.queryParameters['consultant_id']!,
              ),
            );
          } else if (routeSettings!.name!.contains('courses?course_id') &&
              url.queryParameters['tap_id'] == null &&
              url.queryParameters['data'] == null) {
            Uri url = Uri.parse(routeSettings!.name!);

            return MaterialPageRoute(
              settings: RouteSettings(
                  name: 'courses?course_id=${url.queryParameters['course_id']}',
                  arguments: {"course_id": url.queryParameters['course_id']}),
              builder: (context) => CourseDetailScreen(
                courseId: url.queryParameters['course_id']!,
              ),
            );
          } else if (routeSettings!.name!.contains('courses?course_id') &&
              url.queryParameters['tap_id'] != null) {
            //&&url.queryParameters['data']!=null) {
            Uri url = Uri.parse(routeSettings!.name!);

            return MaterialPageRoute(
              settings: RouteSettings(
                  name:
                      'courses?course_id=${url.queryParameters['course_id']}&tap_id=${url.queryParameters['tap_id']}&data=${url.queryParameters['data']}',
                  arguments: {
                    "course_id": url.queryParameters['course_id'],
                    'tap_id': url.queryParameters['tap_id'],
                    'data': url.queryParameters['data']
                  }),
              builder: (context) => CourseDetailScreen(
                  courseId: url.queryParameters['course_id']!,
                  tabid: url.queryParameters['tap_id'],
                  paydata: url.queryParameters['data']),
            );
          } else if (routeSettings!.name!
                  .contains('conslultant?consultant_id') &&
              url.queryParameters['tap_id'] != null) {
            //&&url.queryParameters['data']!=null) {
            Uri url = Uri.parse(routeSettings!.name!);

            //

            return MaterialPageRoute(
              settings: RouteSettings(
                  name:
                      'conslultant?consultant_id=${url.queryParameters['consultant_id']}&tap_id=${url.queryParameters['tap_id']}&data=${url.queryParameters['data']}',
                  arguments: {
                    "consultant_id": url.queryParameters['consultant_id'],
                    'tap_id': url.queryParameters['tap_id'],
                    'data': url.queryParameters['data']
                  }),
              builder: (context) => ConsultantDetailsScreen(
                  consoltantId: url.queryParameters['consultant_id']!,
                  tabid: url.queryParameters['tap_id'],
                  paydata: url.queryParameters['data']),
            );
          } else if (routeSettings!.name!.contains('wallet') &&
              url.queryParameters['tap_id'] != null) {
            //&&url.queryParameters['data']!=null) {
            Uri url = Uri.parse(routeSettings!.name!);

            //

            return MaterialPageRoute(
              settings: RouteSettings(
                  name:
                      'wallet?tap_id=${url.queryParameters['tap_id']}&data=${url.queryParameters['data']}',
                  arguments: {
                    'tap_id': url.queryParameters['tap_id'],
                    'data': url.queryParameters['data']
                  }),
              builder: (context) => WalletScreen(
                  tabid: url.queryParameters['tap_id'],
                  paydata: url.queryParameters['data']),
            );
          }
        },
        onUnknownRoute: (setings) => MaterialPageRoute(
            builder: (con) => Scaffold(
                    body: Stack(children: [
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            iconSize: 20,
                            onPressed: () {
                              Navigator.pop(con);
                            },
                            icon: SvgPicture.asset(
                              AssetsManager.rightArrowIconPath,
                              width: AppSize.w20,
                              height: AppSize.h20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    alignment: Alignment.topLeft,
                  ),
                  Align(
                    child: Center(
                      child: Text('NotFound'),
                    ),
                    alignment: Alignment.center,
                  )
                ])),
            settings: setings),
        routes: {
          // '/': (context) =>(kIsWeb && MediaQuery.of(context).size.width >= 500)?HomeScreen():firstLansh?FirstOpenSreen():SplashScreen(),
          // '/': (context) =>firstLansh?FirstOpenSreen():SplashScreen(),
          '/': (context) =>
              (kIsWeb && MediaQuery.of(context).size.width >= 500 || _isCall)
                  ? HomeScreen()
                  : SplashScreen(),
          //'/': (context) => TechnicalSupportPage(),
          '/langScreen': (context) => LanguageScreen(),
          '/RegisterTypeScreen': (context) => RegisterTypeScreen(),
          '/startCallScreen': (context) {
            endCall();
            return StartCallScreen();
          },

          '/home': (context) => HomeScreen(),

          '/Register_Type': (context) => RegisterTypeScreen(),
          '/wallet': (context) => WalletScreen(),
          '/ForceUpdateScreen': (context) => ForceUpdateScreen(),
          '/OnBoardingScreen': (context) => OnBoardingScreen(),
          // "/Call": (context) => const ZoomCallScreen(),
        },
      );
    }
  }
}

mayAppCheckCall(BuildContext? contexts) {
  _MyAppState().checkAndNavigationCallingPage(contexts);
}

endCall() {
  _MyAppState().endCall();
}
