import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/viagem.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';

class ViagemDetailScreen extends StatelessWidget {
  final Viagem viagem;

  const ViagemDetailScreen({super.key, required this.viagem});

  String _formatarData(String dataHora) {
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dataHora;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final usuario = auth.usuario;
    final token = auth.token;

    final vagasDisponiveis = viagem.vagas - viagem.vagasOcupadas;
    final podeEntrar = viagem.status == 'ABERTA' &&
        usuario != null &&
        !usuario.motorista &&
        vagasDisponiveis > 0;
    final podeCancelar = viagem.status == 'ABERTA' &&
        usuario != null &&
        viagem.motoristaId == usuario.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Viagem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      icon: Icons.trip_origin,
                      iconColor: const Color(0xFF1B5E20),
                      label: 'Origem',
                      value: viagem.origem,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      label: 'Destino',
                      value: viagem.destino,
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      label: 'Data e Hora',
                      value: _formatarData(viagem.dataHoraSaida),
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.event_seat,
                      iconColor: Colors.orange,
                      label: 'Vagas',
                      value:
                          '$vagasDisponiveis de ${viagem.vagas} disponíveis',
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      label: 'Contribuição',
                      value:
                          'R\$ ${viagem.valorContribuicao.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text(
                          'Status',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const Spacer(),
                        _buildStatusBadge(viagem.status),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (podeEntrar)
              Consumer<ViagemProvider>(
                builder: (context, viagemProvider, _) {
                  return ElevatedButton.icon(
                    onPressed: viagemProvider.isLoading
                        ? null
                        : () async {
                            try {
                              await viagemProvider.entrar(
                                viagem.id!,
                                usuario.id!,
                                token!,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Você entrou na viagem!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.directions_car),
                    label: viagemProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Quero Carona!',
                            style: TextStyle(fontSize: 16),
                          ),
                  );
                },
              ),
            if (podeCancelar)
              Consumer<ViagemProvider>(
                builder: (context, viagemProvider, _) {
                  return OutlinedButton.icon(
                    onPressed: viagemProvider.isLoading
                        ? null
                        : () async {
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Cancelar viagem'),
                                content: const Text(
                                  'Tem certeza que deseja cancelar esta viagem?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Não'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text(
                                      'Sim, cancelar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmar != true) return;

                            try {
                              await viagemProvider.cancelar(
                                viagem.id!,
                                token!,
                              );
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Viagem cancelada.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              Navigator.of(context).pop();
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.toString().replaceFirst('Exception: ', ''),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    label: const Text(
                      'Cancelar Viagem',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'ABERTA':
        color = Colors.green;
        break;
      case 'CANCELADA':
        color = Colors.red;
        break;
      case 'CONCLUIDA':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
