package br.edu.ifsp.carona.viagens.dto;

public record UsuarioClientDTO(
        Long id,
        String nome,
        String email,
        Boolean motorista,
        Boolean emailValidado
) {}
