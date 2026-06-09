import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/viagem.dart';

class ViagemService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Viagem>> listarAbertas() async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + ApiConstants.viagensAbertas,
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Viagem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar viagens abertas');
  }

  Future<List<Viagem>> listarPorMotorista(
    int motoristaId,
    String token,
  ) async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + '/api/viagens/motorista/$motoristaId',
    );
    final response = await http.get(
      uri,
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> list = jsonDecode(response.body) as List<dynamic>;
      return list
          .map((e) => Viagem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Erro ao listar viagens do motorista');
  }

  Future<Viagem> buscarPorId(int id) async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + ApiConstants.viagens + '/$id',
    );
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return Viagem.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw Exception('Erro ao buscar viagem');
  }

  Future<Viagem> criar(Map<String, dynamic> dados, String token) async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + ApiConstants.viagens,
    );
    final response = await http.post(
      uri,
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode(dados),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return Viagem.fromJson(body);
    }

    throw Exception(body['erro'] ?? 'Erro ao criar viagem');
  }

  Future<void> entrarNaViagem(
    int viagemId,
    int passageiroId,
    String token,
  ) async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + '/api/viagens/$viagemId/passageiros',
    );
    final response = await http.post(
      uri,
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode({'passageiroId': passageiroId}),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['erro'] ?? 'Erro ao entrar na viagem');
    }
  }

  Future<void> cancelarViagem(int id, String token) async {
    final uri = Uri.parse(
      ApiConstants.viagensBaseUrl + ApiConstants.viagens + '/$id/cancelar',
    );
    final response = await http.patch(
      uri,
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Erro ao cancelar viagem');
    }
  }
}
