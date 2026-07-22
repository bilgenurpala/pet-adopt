import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/pets/providers/favorites_provider.dart';
import 'features/pets/providers/pet_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider<FavoritesProvider>(
          create: (_) => FavoritesProvider(),
        ),
        ChangeNotifierProvider<PetProvider>(create: (_) => PetProvider()),
      ],
      child: const PetStoreApp(),
    ),
  );
}

class PetStoreApp extends StatefulWidget {
  const PetStoreApp({super.key});

  @override
  State<PetStoreApp> createState() => _PetStoreAppState();
}

class _PetStoreAppState extends State<PetStoreApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _router ??= AppRouter.createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pet Adoption',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router!,
    );
  }
}
