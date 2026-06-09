import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';
import '../../models/viagem.dart';
import '../viagens/viagem_detail_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregarViagens());
  }

  Future<void> _carregarViagens() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario?.motorista == true &&
        auth.usuario?.id != null &&
        auth.token != null) {
      await context.read<ViagemProvider>().carregarMinhasViagens(
            auth.usuario!.id!,
            auth.token!,
          );
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  String _formatarData(String? dataHora) {
    if (dataHora == null) return '-';
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dataHora;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuario;

    if (usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final inicial = usuario.nome.isNotEmpty
        ? usuario.nome[0].toUpperCase()
        : '?';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Avatar e nome
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFF1B5E20),
                  child: Text(
                    inicial,
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  usuario.nome,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: usuario.motorista
                        ? const Color(0xFF1B5E20).withOpacity(0.15)
                        : Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    usuario.motorista ? 'Motorista' : 'Passageiro',
                    style: TextStyle(
                      color: usuario.motorista
                          ? const Color(0xFF1B5E20)
                          : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Informações
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informações',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.email_outlined, 'E-mail', usuario.email),
                  const Divider(height: 16),
                  _infoRow(Icons.phone_outlined, 'Telefone', usuario.telefone),
                  const Divider(height: 16),
                  _infoRow(
                    Icons.verified_outlined,
                    'E-mail validado',
                    usuario.emailValidado ? 'Sim' : 'Não',
                  ),
                  if (usuario.criadoEm != null) ...[
                    const Divider(height: 16),
                    _infoRow(
                      Icons.calendar_today_outlined,
                      'Membro desde',
                      _formatarData(usuario.criadoEm),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Viagens (apenas motorista)
          if (usuario.motorista) ...[
            const Text(
              'Minhas viagens criadas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Consumer<ViagemProvider>(
              builder: (context, viagemProvider, _) {
                if (viagemProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final minhasViagens = viagemProvider.minhasViagens;

                if (minhasViagens.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Você ainda não criou nenhuma viagem.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: minhasViagens.length,
                  itemBuilder: (context, index) {
                    final Viagem viagem = minhasViagens[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.directions_car,
                          color: Color(0xFF1B5E20),
                        ),
                        title: Text(
                          '${viagem.origem} → ${viagem.destino}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          _formatarData(viagem.dataHoraSaida) +
                              '  •  ${viagem.status}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ViagemDetailScreen(viagem: viagem),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
          ],
          // Botão sair
          OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'Sair',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
