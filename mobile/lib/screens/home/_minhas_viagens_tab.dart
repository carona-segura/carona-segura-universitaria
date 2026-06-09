import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';
import '../../models/viagem.dart';
import '../viagens/viagem_detail_screen.dart';

class MinhasViagensTab extends StatefulWidget {
  const MinhasViagensTab({super.key});

  @override
  State<MinhasViagensTab> createState() => _MinhasViagensTabState();
}

class _MinhasViagensTabState extends State<MinhasViagensTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final auth = context.read<AuthProvider>();
    final viagemProvider = context.read<ViagemProvider>();
    if (auth.usuario?.id != null && auth.token != null && auth.usuario!.motorista) {
      await viagemProvider.carregarMinhasViagens(
        auth.usuario!.id!,
        auth.token!,
      );
    }
  }

  String _formatarData(String dataHora) {
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dataHora;
    }
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'ABERTA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'CONCLUIDA':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.usuario!.motorista) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Apenas motoristas podem ver\nsuas viagens criadas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Consumer<ViagemProvider>(
      builder: (context, viagemProvider, _) {
        if (viagemProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final minhasViagens = viagemProvider.minhasViagens;

        if (minhasViagens.isEmpty) {
          return RefreshIndicator(
            onRefresh: _carregar,
            child: ListView(
              children: const [
                SizedBox(height: 160),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Você ainda não criou viagens.',
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
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: minhasViagens.length,
            itemBuilder: (context, index) {
              final Viagem viagem = minhasViagens[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ViagemDetailScreen(viagem: viagem),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${viagem.origem} → ${viagem.destino}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _corStatus(viagem.status)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                viagem.status,
                                style: TextStyle(
                                  color: _corStatus(viagem.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _formatarData(viagem.dataHoraSaida),
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.event_seat,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${viagem.vagas - viagem.vagasOcupadas} vagas disponíveis',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            const Spacer(),
                            Text(
                              'R\$ ${viagem.valorContribuicao.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF1B5E20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
