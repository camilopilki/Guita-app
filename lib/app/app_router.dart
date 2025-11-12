import 'package:go_router/go_router.dart';
import '../features/welcome/welcome_page.dart';
import '../features/connect/connect_page.dart';
import '../features/home/home_page.dart';
import '../features/dashboard/sensors_page.dart';

final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomePage()),
    GoRoute(path: '/connect',  builder: (_, __) => const ConnectPage()),
    GoRoute(path: '/home',     builder: (_, __) => const HomePage()),
    GoRoute(path: '/dashboard', builder: (_, __) => const SensorsPage()),
  ],
);
