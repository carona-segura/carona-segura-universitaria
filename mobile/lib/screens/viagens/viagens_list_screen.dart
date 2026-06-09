import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';
import '../../models/viagem.dart';
import 'viagem_detail_screen.dart';

class ViagensListScreen extends StatefulWidget {
  const ViagensListScreen({super.key});

  @override
  State<ViagensListScreen> createState() => _ViagensListScreenState();
}

class _ViagensListScreenState extends State<ViagensListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViagemProvider>().carregarAbertas();
    });
  }

  String _formatarData(String dataHora) {
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dataHora;
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthProvider>().usuario;

    return Scaffold(
      body: Consumer<ViagemProvider>(
        builder: (context, viagemProvider, _) {
          if (viagemProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final viagens = viagemProvider.viagens;

          if (viagens.isEmpty) {
            return RefreshIndicator(
              onRefresh: viagemProvider.carregarAbertas,
              child: ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma viagem disponível',
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
            onRefresh: viagemProvider.carregarAbertas,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: viagens.length,
              itemBuilder: (context, index) {
                final Viagem viagem = viagens[index];
                final vagasDisponiveis = viagem.vagas - viagem.vagasOcupadas;

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
                              const Icon(
                                Icons.trip_origin,
                                size: 14,
                                color: Color(0xFF1B5E20),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  viagem.origem,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Container(
                              width: 1.5,
                              height: 10,
                              color: Colors.grey[300],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  viagem.destino,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatarData(viagem.dataHoraSaida),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.event_seat,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$vagasDisponiveis vaga${vagasDisponiveis != 1 ? 's' : ''} disponível${vagasDisponiveis != 1 ? 'is' : ''}',
                                style: TextStyle(
                                  color: vagasDisponiveis > 0
                                      ? Colors.grey
                                      : Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'R\$ ${viagem.valorContribuicao.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
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
      ),
      floatingActionButton: (usuario?.motorista ?? false)
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).pushNamed('/criar-viagem');
                if (context.mounted) {
                  context.read<ViagemProvider>().carregarAbertas();
                }
              },
              tooltip: 'Nova viagem',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
