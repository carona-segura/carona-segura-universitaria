package br.edu.ifsp.carona.viagens.dto;

import jakarta.validation.constraints.NotNull;

public record PassageiroRequestDTO(

        @NotNull(message = "ID do passageiro é obrigatório")
        Long passageiroId
) {}
