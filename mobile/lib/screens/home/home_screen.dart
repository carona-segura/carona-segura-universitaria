import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';
import '../../providers/notificacao_provider.dart';
import '../viagens/viagens_list_screen.dart';
import '../notificacoes/notificacoes_screen.dart';
import '../perfil/perfil_screen.dart';
import '_minhas_viagens_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarDados());
  }

  Future<void> _carregarDados() async {
    final authProvider = context.read<AuthProvider>();
    final viagemProvider = context.read<ViagemProvider>();
    final notificacaoProvider = context.read<NotificacaoProvider>();

    await viagemProvider.carregarAbertas();

    if (authProvider.usuario?.id != null) {
      await notificacaoProvider.carregar(authProvider.usuario!.id!);
    }
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final naoLidas = context.watch<NotificacaoProvider>().naoLidas;

    final List<Widget> telas = [
      const ViagensListScreen(),
      const MinhasViagensTab(),
      const NotificacoesScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carona Segura',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: telas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E20),
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Viagens',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Minhas Viagens',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications),
                if (naoLidas > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        naoLidas > 9 ? '9+' : '$naoLidas',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notificações',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
