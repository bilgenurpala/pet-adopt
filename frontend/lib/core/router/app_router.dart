import 'package:go_router/go_router.dart';

import '../../features/adoptions/screens/adoption_applications_page.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/pets/screens/favorites_page.dart';
import '../../features/profile/screens/my_pet_listings_page.dart';
import '../widgets/main_navigation.dart';
import 'route_names.dart';
import '../../features/profile/screens/settings_page.dart';
import '../../features/profile/screens/contact_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: RouteNames.home,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (!authProvider.isInitialized) {
          return null;
        }

        final isLoggedIn = authProvider.isAuthenticated;
        final isOnLoginPage = state.matchedLocation == RouteNames.login;

        if (!isLoggedIn && !isOnLoginPage) {
          return RouteNames.login;
        }

        if (isLoggedIn && isOnLoginPage) {
          return RouteNames.home;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const MainNavigation(),
        ),
        GoRoute(
          path: RouteNames.favorites,
          builder: (context, state) => const FavoritesPage(),
        ),
        GoRoute(
          path: RouteNames.myPetListings,
          builder: (context, state) => const MyPetListingsPage(),
        ),
        GoRoute(
          path: RouteNames.adoptionApplications,
          builder: (context, state) => const AdoptionApplicationsPage(),
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: RouteNames.contact,
          builder: (context, state) => const ContactPage(),
        ),
      ],
    );
  }
}
