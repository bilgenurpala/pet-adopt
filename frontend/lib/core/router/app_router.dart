import 'package:go_router/go_router.dart';
import '../../features/pets/screens/home_page.dart';
import 'route_names.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
