import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/viagem_provider.dart';

class CriarViagemScreen extends StatefulWidget {
  const CriarViagemScreen({super.key});

  @override
  State<CriarViagemScreen> createState() => _CriarViagemScreenState();
}

class _CriarViagemScreenState extends State<CriarViagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _origemController = TextEditingController();
  final _destinoController = TextEditingController();
  final _valorController = TextEditingController();
  int _vagas = 1;
  DateTime? _dataHoraSaida;

  @override
  void dispose() {
    _origemController.dispose();
    _destinoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  Future<void> _selecionarDataHora() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null || !mounted) return;

    setState(() {
      _dataHoraSaida = DateTime(
        data.year,
        data.month,
        data.day,
        hora.hour,
        hora.minute,
      );
    });
  }

  String _formatarDataHora(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dataHoraSaida == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione a data e hora de saída'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final viagemProvider = context.read<ViagemProvider>();

    final dados = {
      'motoristaId': auth.usuario!.id,
      'origem': _origemController.text.trim(),
      'destino': _destinoController.text.trim(),
      'dataHoraSaida': _dataHoraSaida!.toIso8601String(),
      'vagas': _vagas,
      'valorContribuicao': double.parse(
        _valorController.text.trim().replaceAll(',', '.'),
      ),
    };

    try {
      await viagemProvider.criar(dados, auth.token!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Viagem criada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Viagem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _origemController,
                decoration: const InputDecoration(
                  labelText: 'Origem',
                  prefixIcon: Icon(Icons.trip_origin, color: Color(0xFF1B5E20)),
                  hintText: 'Ex: Campus UFMG, Pampulha',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o local de origem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destinoController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  prefixIcon: Icon(Icons.location_on, color: Colors.red),
                  hintText: 'Ex: Centro de BH',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o destino';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Data e Hora
              InkWell(
                onTap: _selecionarDataHora,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data e Hora de Saída',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _dataHoraSaida != null
                        ? _formatarDataHora(_dataHoraSaida!)
                        : 'Selecionar data e hora',
                    style: TextStyle(
                      color: _dataHoraSaida != null
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Vagas
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Número de vagas',
                  prefixIcon: const Icon(Icons.event_seat),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _vagas,
                    isDense: true,
                    items: List.generate(4, (i) => i + 1)
                        .map(
                          (n) => DropdownMenuItem(
                            value: n,
                            child: Text('$n vaga${n > 1 ? 's' : ''}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _vagas = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor de contribuição (R\$)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'Ex: 5.00',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor de contribuição';
                  }
                  final v = double.tryParse(
                    value.trim().replaceAll(',', '.'),
                  );
                  if (v == null || v < 0) {
                    return 'Valor inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              Consumer<ViagemProvider>(
                builder: (context, viagemProvider, _) {
                  return viagemProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton.icon(
                          onPressed: _criar,
                          icon: const Icon(Icons.add_road),
                          label: const Text(
                            'Criar Viagem',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
