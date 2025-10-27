import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'models/models.dart';
import 'screens/project_list_screen.dart';
import 'screens/project_detail_screen.dart';
import 'services/project_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repo = await ProjectRepository.bootstrap();
  runApp(App(repo: repo));
}

class App extends StatelessWidget {
  final ProjectRepository repo;
  const App({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const ProjectListScreen(),
          routes: [
            GoRoute(
              path: 'project/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ProjectDetailScreen(projectId: id);
              },
            ),
          ],
        ),
      ],
    );

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ProjectStore(repo))],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'DIY Home Planner',
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}
