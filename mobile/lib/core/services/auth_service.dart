import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/usuario.dart';

class AuthService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> login(String email, String senha) async {
    final uri = Uri.parse(ApiConstants.usuariosBaseUrl + ApiConstants.login);
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(body['erro'] ?? 'Erro ao fazer login');
  }

  Future<Usuario> cadastrar(
    String nome,
    String email,
    String senha,
    String telefone,
    bool motorista,
  ) async {
    final uri = Uri.parse(ApiConstants.usuariosBaseUrl + ApiConstants.cadastro);
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'telefone': telefone,
        'motorista': motorista,
      }),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201) {
      return Usuario.fromJson(body);
    }

    throw Exception(body['erro'] ?? 'Erro ao cadastrar usuário');
  }

  Future<Usuario> buscarPerfil(int id, String token) async {
    final uri = Uri.parse(
      ApiConstants.usuariosBaseUrl + ApiConstants.usuarios + '/$id',
    );
    final response = await http.get(
      uri,
      headers: {
        ..._headers,
        'Authorization': 'Bearer $token',
      },
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return Usuario.fromJson(body);
    }

    throw Exception(body['erro'] ?? 'Erro ao buscar perfil');
  }
}
