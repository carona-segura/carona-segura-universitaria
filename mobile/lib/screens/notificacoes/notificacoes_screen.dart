import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notificacao_provider.dart';
import '../../models/notificacao.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final auth = context.read<AuthProvider>();
    if (auth.usuario?.id != null) {
      await context.read<NotificacaoProvider>().carregar(auth.usuario!.id!);
    }
  }

  Future<void> _marcarTodasLidas() async {
    final provider = context.read<NotificacaoProvider>();
    final ids = provider.notificacoes
        .where((n) => !n.lida && n.id != null)
        .map((n) => n.id!)
        .toList();

    if (ids.isEmpty) return;

    await provider.marcarLidas(ids);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notificações marcadas como lidas'),
        backgroundColor: Color(0xFF1B5E20),
      ),
    );
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VIAGEM_CRIADA':
        return Icons.directions_car;
      case 'VIAGEM_CANCELADA':
        return Icons.cancel;
      case 'PASSAGEIRO_ENTROU':
        return Icons.person_add;
      case 'VIAGEM_CONCLUIDA':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  Color _corPorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VIAGEM_CRIADA':
        return const Color(0xFF1B5E20);
      case 'VIAGEM_CANCELADA':
        return Colors.red;
      case 'PASSAGEIRO_ENTROU':
        return Colors.blue;
      case 'VIAGEM_CONCLUIDA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatarData(String? dataHora) {
    if (dataHora == null) return '';
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dataHora;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<NotificacaoProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final notificacoes = provider.notificacoes;

          if (notificacoes.isEmpty) {
            return RefreshIndicator(
              onRefresh: _carregar,
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma notificação',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _carregar,
            child: Column(
              children: [
                if (provider.naoLidas > 0)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _marcarTodasLidas,
                        icon: const Icon(Icons.done_all,
                            color: Color(0xFF1B5E20)),
                        label: const Text(
                          'Marcar todas como lidas',
                          style: TextStyle(color: Color(0xFF1B5E20)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1B5E20)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: notificacoes.length,
                    itemBuilder: (context, index) {
                      final Notificacao notif = notificacoes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: notif.lida ? null : Colors.green[50],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: notif.lida
                              ? BorderSide.none
                              : BorderSide(
                                  color: Colors.green[200]!,
                                  width: 1,
                                ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                _corPorTipo(notif.tipo).withOpacity(0.15),
                            child: Icon(
                              _iconePorTipo(notif.tipo),
                              color: _corPorTipo(notif.tipo),
                              size: 20,
                            ),
                          ),
                          title: Text(
                            notif.titulo,
                            style: TextStyle(
                              fontWeight: notif.lida
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Text(
                                notif.mensagem,
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatarData(notif.criadoEm),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: notif.lida
                              ? null
                              : Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1B5E20),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
