package br.edu.ifsp.carona.usuarios.dto;

import br.edu.ifsp.carona.usuarios.entity.Usuario;

import java.time.LocalDateTime;

public record UsuarioResponseDTO(
        Long id,
        String nome,
        String email,
        String telefone,
        Boolean motorista,
        Boolean emailValidado,
        String role,
        LocalDateTime criadoEm
) {
    public static UsuarioResponseDTO fromEntity(Usuario u) {
        return new UsuarioResponseDTO(
                u.getId(),
                u.getNome(),
                u.getEmail(),
                u.getTelefone(),
                u.getMotorista(),
                u.getEmailValidado(),
                u.getRole().name(),
                u.getCriadoEm()
        );
    }
}
