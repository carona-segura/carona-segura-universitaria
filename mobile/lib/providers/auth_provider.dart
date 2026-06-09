import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';
import '../models/usuario.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? usuario;
  String? token;
  bool isLoading = false;
  String? erro;

  final AuthService _authService = AuthService();

  bool get isLoggedIn => token != null && usuario != null;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedId = prefs.getInt('usuarioId');

      if (savedToken != null && savedId != null) {
        token = savedToken;
        final authService = AuthService();
        usuario = await authService.buscarPerfil(savedId, savedToken);
      }
    } catch (e) {
      // Token expirado ou inválido — faz logout silencioso
      token = null;
      usuario = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('usuarioId');
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String senha) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      final authService = AuthService();
      final resultado = await authService.login(email, senha);

      token = resultado['token'] as String;

      // Decodifica o JWT manualmente para extrair o id (sem biblioteca externa)
      final partes = token!.split('.');
      final payload = partes[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      final usuarioId = claims['id'] as int;

      // Persiste token e id no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token!);
      await prefs.setInt('usuarioId', usuarioId);

      // Busca perfil completo no ms-usuarios
      usuario = await authService.buscarPerfil(usuarioId, token!);
    } catch (e) {
      erro = e.toString().replaceAll('Exception: ', '');
      token = null;
      usuario = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cadastrar(
    String nome,
    String email,
    String senha,
    String telefone,
    bool motorista,
  ) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      await _authService.cadastrar(nome, email, senha, telefone, motorista);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuarioId');
    token = null;
    usuario = null;
    notifyListeners();
  }
}
