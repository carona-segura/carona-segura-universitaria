import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/viagem_provider.dart';
import 'providers/notificacao_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/cadastro_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/viagens/viagens_list_screen.dart';
import 'screens/viagens/criar_viagem_screen.dart';
import 'screens/notificacoes/notificacoes_screen.dart';
import 'screens/perfil/perfil_screen.dart';

void main() {
  runApp(const CaronaSeguraApp());
}

class CaronaSeguraApp extends StatelessWidget {
  const CaronaSeguraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ViagemProvider()),
        ChangeNotifierProvider(create: (_) => NotificacaoProvider()),
      ],
      child: MaterialApp(
        title: 'Carona Segura Universitária',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B5E20),
            primary: const Color(0xFF1B5E20),
            secondary: const Color(0xFF4CAF50),
          ),
          primaryColor: const Color(0xFF1B5E20),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1B5E20),
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
            ),
          ),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
          Locale('en', 'US'),
        ],
        locale: const Locale('pt', 'BR'),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/cadastro': (context) => const CadastroScreen(),
          '/home': (context) => const HomeScreen(),
          '/viagens': (context) => const ViagensListScreen(),
          '/criar-viagem': (context) => const CriarViagemScreen(),
          '/notificacoes': (context) => const NotificacoesScreen(),
          '/perfil': (context) => const PerfilScreen(),
        },
      ),
    );
  }
}
