import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/AppConstData/setlanguage.dart';
import 'package:movers_lorry_owner/AppConstData/string_file.dart';
import 'package:movers_lorry_owner/Screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppConstData/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Add global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('=== Global Flutter Error ===');
    print('Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  // Handle platform errors
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    print('=== Global Platform Error ===');
    print('Error: $error');
    print('Stack trace: $stack');
    return true;
  };
  
  // Fix for text input issues
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Force proper text input mode
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await permission();
  final localeLanuage = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: localeLanuage));
}

class MyApp extends StatelessWidget {
  final SharedPreferences _localeLanuage;

  const MyApp({Key? key, required SharedPreferences prefs})
      : _localeLanuage = prefs,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocaleModel(_localeLanuage),
      child: Consumer<LocaleModel>(
        builder: (context, localeModel, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // iPhone X design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'LorryOwner',
            getPages: getpage,
            locale: localeModel.locale,
            initialRoute: Routes.splashScreen,
            translations: AppTranslations(),
            theme: ThemeData(
              useMaterial3: false,
              scaffoldBackgroundColor: Colors.white,
              canvasColor: Colors.white,
              cardColor: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              dividerColor: Colors.transparent,
              fontFamily: "urbani_regular",
              primaryColor: const Color(0xff1347FF),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xff194BFB),
                surface: Colors.white,
              ),
              // Fix for text input issues
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xff194BFB)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: false,
              scaffoldBackgroundColor: Colors.white,
              canvasColor: Colors.white,
              cardColor: Colors.white,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              dividerColor: Colors.transparent,
              fontFamily: "urbani_regular",
              primaryColor: const Color(0xff1347FF),
              colorScheme: ColorScheme.fromSwatch().copyWith(
                primary: const Color(0xff194BFB),
                surface: Colors.white,
              ),
            ),
            home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

permission() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Don't crash the app, just log the issue
      print('Location permission denied by user');
      return;
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Don't crash the app, just log the issue
    print('Location permission permanently denied');
    return;
  }
  
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    print('Location services are disabled');
    return;
  }
}

// login :- 8511753704
// password :- 123