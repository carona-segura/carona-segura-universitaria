import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/notificacao.dart';

class NotificacaoService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Notificacao>> listarPorUsuario(int usuarioId) async {
    final uri = Uri.parse(
      ApiConstants.notificacoesBaseUrl +
          '/api/notificacoes/usuario/$usuarioId',
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Notificacao.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar notificações');
  }

  Future<int> contarNaoLidas(int usuarioId) async {
    final uri = Uri.parse(
      ApiConstants.notificacoesBaseUrl +
          '/api/notificacoes/usuario/$usuarioId/contar',
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['total'] as int? ?? 0;
    }

    return 0;
  }

  Future<void> marcarComoLidas(List<int> ids) async {
    final uri = Uri.parse(
      ApiConstants.notificacoesBaseUrl + '/api/notificacoes/marcar-lidas',
    );
    await http.patch(
      uri,
      headers: _headers,
      body: jsonEncode({'ids': ids}),
    );
  }
}
