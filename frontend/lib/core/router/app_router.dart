import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_shell_page.dart';

import '../../features/adoptions/screens/adoption_applications_page.dart';

import '../../features/auth/providers/auth_provider.dart';

import '../../features/auth/screens/login_screen.dart';

import '../../features/pets/screens/favorites_page.dart';

import '../../features/profile/screens/contact_page.dart';

import '../../features/profile/screens/my_activity_page.dart';

import '../../features/profile/screens/my_pet_listings_page.dart';

import '../widgets/main_navigation.dart';

import 'route_names.dart';

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

        final currentUser = authProvider.currentUser;

        final isAdmin = currentUser?.isAdmin ?? false;

        final currentLocation = state.matchedLocation;

        final isOnLoginPage = currentLocation == RouteNames.login;

        final isOnAdminPage = currentLocation.startsWith(RouteNames.admin);

        if (!isLoggedIn) {
          return isOnLoginPage ? null : RouteNames.login;
        }

        if (isAdmin) {
          if (!isOnAdminPage) {
            return RouteNames.admin;
          }

          return null;
        }

        if (isOnLoginPage || isOnAdminPage) {
          return RouteNames.home;
        }

        return null;
      },

      routes: [
        GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),

        GoRoute(
          path: RouteNames.home,

          builder: (_, _) => const MainNavigation(),
        ),

        GoRoute(
          path: RouteNames.admin,

          builder: (_, _) => const AdminShellPage(),
        ),

        GoRoute(
          path: RouteNames.favorites,

          builder: (_, _) => const FavoritesPage(),
        ),

        GoRoute(
          path: RouteNames.myActivity,

          builder: (_, _) => const MyActivityPage(),
        ),

        // Eski bağlantıların bozulmaması için korunuyor.
        GoRoute(
          path: RouteNames.myPetListings,

          builder: (_, _) => const MyPetListingsPage(),
        ),

        GoRoute(
          path: RouteNames.adoptionApplications,

          builder: (_, _) => const AdoptionApplicationsPage(),
        ),

        GoRoute(
          path: RouteNames.contact,

          builder: (_, _) => const ContactPage(),
        ),
      ],
    );
  }
}
