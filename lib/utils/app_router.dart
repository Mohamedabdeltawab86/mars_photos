import 'package:go_router/go_router.dart';
import 'package:mars_photos/data/provider/mars_model.dart';
import 'package:mars_photos/data/repo/repo.dart';
import 'package:mars_photos/ui/screens/home.dart';
import 'package:mars_photos/utils/router_constants.dart';
import 'package:provider/provider.dart';

import '../ui/screens/settings.dart';

GoRouter router() {
  final MarsModel marsModel = MarsModel(repo: Repo());
  return GoRouter(
    routes: [
      GoRoute(
        path: "/",
        builder: (context, state) => Provider<MarsModel>.value(
            value: marsModel, child: Home(earthDate: state.extra as DateTime?)),
      ),
      GoRoute(
        path: settingsPath,
        builder: (context, state) => const Settings(),
      ),
    ],
  );
}
