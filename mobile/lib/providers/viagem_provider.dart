import 'package:flutter/material.dart';
import '../core/services/viagem_service.dart';
import '../models/viagem.dart';

class ViagemProvider extends ChangeNotifier {
  List<Viagem> viagens = [];
  List<Viagem> minhasViagens = [];
  bool isLoading = false;
  String? erro;

  final ViagemService _viagemService = ViagemService();

  Future<void> carregarAbertas() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      viagens = await _viagemService.listarAbertas();
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarMinhasViagens(int motoristaId, String token) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      minhasViagens = await _viagemService.listarPorMotorista(
        motoristaId,
        token,
      );
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> criar(Map<String, dynamic> dados, String token) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      final novaViagem = await _viagemService.criar(dados, token);
      viagens.add(novaViagem);
      minhasViagens.add(novaViagem);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> entrar(
    int viagemId,
    int passageiroId,
    String token,
  ) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      await _viagemService.entrarNaViagem(viagemId, passageiroId, token);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelar(int id, String token) async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      await _viagemService.cancelarViagem(id, token);
      viagens.removeWhere((v) => v.id == id);
      minhasViagens.removeWhere((v) => v.id == id);
    } catch (e) {
      erro = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
