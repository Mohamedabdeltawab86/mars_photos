import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mars_photos/data/db/init_db.dart';
import 'package:mars_photos/data/provider/mars_model.dart';
import 'package:mars_photos/data/repo/repo.dart';
import 'package:mars_photos/utils/app_router.dart';
import 'package:mars_photos/utils/color_schemes.g.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mars_photos/utils/constants.dart';
import 'package:mars_photos/utils/typography.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDB();
  Provider.debugCheckInvalidValueType = null;
  runApp(ChangeNotifierProvider(
    create: (context) => MarsModel(repo: Repo()),
    child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box(settingsKey).listenable(),
        builder: (_, box, __) {
          final bool isDark =
              Hive.box(settingsKey).get(isDarkKey, defaultValue: false);
          final String lang =
              Hive.box(settingsKey).get(langKey, defaultValue: defaultLang);
          return Sizer(
            builder: (context, orientation, deviceType) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: "Mars Photo App",
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: Locale(lang),
                theme: ThemeData(
                  colorScheme: lightColorScheme,
                  useMaterial3: true,
                  textTheme: textTheme,
                ),
                darkTheme: ThemeData(
                  colorScheme: darkColorScheme,
                  useMaterial3: true,
                  textTheme: textTheme,
                ),
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                routerConfig: router(),
              );
            }
          );
        });
  }
}
