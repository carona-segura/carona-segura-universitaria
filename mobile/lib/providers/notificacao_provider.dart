import 'package:flutter/material.dart';
import '../core/services/notificacao_service.dart';
import '../models/notificacao.dart';

class NotificacaoProvider extends ChangeNotifier {
  List<Notificacao> notificacoes = [];
  int naoLidas = 0;
  bool isLoading = false;

  final NotificacaoService _service = NotificacaoService();

  Future<void> carregar(int usuarioId) async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.listarPorUsuario(usuarioId),
        _service.contarNaoLidas(usuarioId),
      ]);
      notificacoes = results[0] as List<Notificacao>;
      naoLidas = results[1] as int;
    } catch (_) {
      notificacoes = [];
      naoLidas = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> marcarLidas(List<int> ids) async {
    try {
      await _service.marcarComoLidas(ids);
      notificacoes = notificacoes.map((n) {
        if (ids.contains(n.id)) {
          return Notificacao(
            id: n.id,
            destinatarioId: n.destinatarioId,
            tipo: n.tipo,
            titulo: n.titulo,
            mensagem: n.mensagem,
            lida: true,
            criadoEm: n.criadoEm,
          );
        }
        return n;
      }).toList();
      naoLidas = notificacoes.where((n) => !n.lida).length;
      notifyListeners();
    } catch (_) {}
  }
}
