import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tekrar/tekrar3_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: uygulamaRotalari,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Column(mainAxisAlignment: .center)),
    );
  }
}

final GoRouter uygulamaRotalari = GoRouter(
  initialLocation: '/anasayfa',
  routes: [
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return AnaKasaEkrani(ekranGovdesi: child);
      },
      routes: [
        GoRoute(
          // Optional, add name to your routes. Allows you navigate by name instead of path
          path: '/anasayfa',
          builder: (context, state) =>
              const Center(child: Text("1234")),
        ),
        GoRoute(
          path: '/vitrin',
          builder: (context, state) => const VitrinEkrani(),
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const ProfilEkrani(),
        ),
      ],
    ),
  ],
);
