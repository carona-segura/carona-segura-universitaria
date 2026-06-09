package br.edu.ifsp.carona.usuarios.dto;

import jakarta.validation.constraints.*;

public record UsuarioRequestDTO(

        @NotBlank(message = "Nome é obrigatório")
        String nome,

        @Email(message = "E-mail inválido")
        @NotBlank(message = "E-mail é obrigatório")
        @Pattern(
                regexp = "^[^@]+@(aluno\\.ifsp\\.edu\\.br|ifsp\\.edu\\.br)$",
                message = "E-mail deve pertencer ao domínio @aluno.ifsp.edu.br ou @ifsp.edu.br"
        )
        String email,

        @NotBlank(message = "Senha é obrigatória")
        @Size(min = 6, message = "Senha deve ter no mínimo 6 caracteres")
        String senha,

        @NotBlank(message = "Telefone é obrigatório")
        String telefone,

        Boolean motorista
) {}
