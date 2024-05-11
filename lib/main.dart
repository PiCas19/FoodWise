import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/appwrite/auth_api.dart';
import 'widgets/authentication_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en', 'US'), Locale('it', 'IT')],
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: const Locale('en', 'US'),
        child: ChangeNotifierProvider(
          create: (context) => AuthAPI(),
          child: const MyApp(),
        ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodWise',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: const AuthenticationWrapper(),
      theme: ThemeData(
        tabBarTheme: const TabBarTheme(
          indicatorColor: Color.fromARGB(240, 255, 213, 63),
        ),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFFE91052),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: Theme(
            data: Theme.of(context).copyWith(
              canvasColor: const Color.fromARGB(240, 255, 213, 63),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
